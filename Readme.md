

现在目标机器启动daemon进程，进行自动化同步


本地插件每秒会执行同步命令，将文件同步到服务器



-------------



# server 准备

查看时候已经安装rsync

将配置文件，密码文件发送到server，启动rsync daemon服务，并加到开机启动项

一定要注意密钥
 ```
 chmod 600 /etc/
 chmod 600 /etc/


 sh ./server-install.sh cos-cloud-monitor /root/cos_cloud_monitor root 9.134.25.215 It-is-just-rsync-passwd
 ```

 ```
 ```

 ```
 ```

 ```
 ```

 ```
 ```

 ```
 ```


# client  准备



# 启动vim更改文件，查看文件同步状态
