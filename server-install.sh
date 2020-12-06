#!/bin/bash

# sh ./server-install.sh <model-name> <sync-path> <user> <ip> <passwd>


sync_model=$1
sync_path=$2
user=$3
ip=$4
passwd=$5

rsyncd_passwd_file="/etc/rsyncd.${sync_model}.passwd.conf"
rsyncd_passwd_content="${user}:${passwd}"

if [ ! -f "$rsyncd_passwd_file" ]; then
  touch "$rsyncd_passwd_file"
  chmod 600 "${rsyncd_passwd_file}"
fi
truncate -c --size 0 "${rsyncd_passwd_file}"
echo ${rsyncd_passwd_content} >> ${rsyncd_passwd_file}
if [ $? -ne 0 ]; then
    echo "[Create Sync Passwd File] Fail (${rsyncd_passwd_file})"
else
    echo "[Create Sync Passwd File] Success (${rsyncd_passwd_file})"
fi

rsyncd_conf_content=""
rsyncd_conf_file="/etc/rsyncd.conf"
if [ ! -f "$rsyncd_conf_file" ]; then
  touch "$rsyncd_conf_file"
  rsyncd_conf_content="
  \nuid = root\n
  gid = root\n
  use chroot = no\n
  max connections = 10\n
  pid file = /var/run/rsyncd.pid\n
  lock file = /var/run/rsync.lock\n
  log file = /var/log/rsyncd.log\n\n"
fi
rsyncd_conf_content="
${rsyncd_conf_content}\n
[${sync_model}]\n
# sync-path\n
path = ${sync_path}\n
read only = false\n
list = false\n
auth users = ${user}\n
secrets file = ${rsyncd_passwd_file}\n
"

mkdir ${sync_path}
echo -e ${rsyncd_conf_content} >> ${rsyncd_conf_file}

if [ $? -ne 0 ]; then
    echo "[Update Sync Conf] Fail (${rsyncd_conf_file})"
else
    echo "[Update Sync Conf] Success (${rsyncd_conf_file})"
fi

# systemctl restart rsyncd >> /dev/null

rsync --daemon --config=${rsyncd_conf_file}
if [ $? -ne 0 ]; then
    echo "[Restart Rsyncd] Fail"
else
    echo "[Restart Rsyncd] Success"
fi

ps -ef | grep rsync >> /dev/null
# netstat -lntup|grep 873


test_client_passwd_file="./test_client_passwd_file"
if [ ! -f "$test_client_passwd_file" ]; then
  touch "$test_client_passwd_file"
  chmod 600 "$test_client_passwd_file"
fi
truncate -c --size 0 "${test_client_passwd_file}"
echo ${passwd} >> ${test_client_passwd_file}


rsync -avz ${test_client_passwd_file} --password-file=${test_client_passwd_file} ${user}@${ip}::${sync_model}
if [ $? -ne 0 ]; then
    echo "[Test Sync] Fail"
else
    echo "[Test Sync] Success"
fi


