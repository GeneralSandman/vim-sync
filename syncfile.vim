
function! GetCurrentSyncModel() abort

    let vim_sync_configs = g:vim_sync_configs
    let model_name = ''

    let self_path = expand("%:p")
    let self_fold = expand("%:p:h")
    if self_fold[len(self_fold) - 1] != "/"
        let self_fold = self_fold . "/"
    endif

    for project_name in keys(vim_sync_configs)
        if !has_key(vim_sync_configs[project_name], 'client_sync_path')
            continue
        endif

        let client_sync_path = vim_sync_configs[project_name]['client_sync_path']
        if self_path =~ "^" . client_sync_path
            let model_name = project_name
            return model_name
        endif
    endfor

    return model_name

endfunction

function! SetModelDefaultConfig(model_name) abort

    let model_config = g:vim_sync_configs[a:model_name]

    if !has_key(model_config, 'user') || !has_key(model_config, 'ip') || !has_key(model_config, 'passwd') 
        return false
    endif

    if !has_key(model_config, 'auto_sync_interval_ms') 
        let model_config['auto_sync_interval_ms'] = 10000
    endif

    if !has_key(model_config, 'client_sync_path') || model_config['client_sync_path'] == ""
        " echo "[Vim-Sync-File-Plugin]client_sync_path is invalid"
        return false
    endif


    let client_sync_path = model_config['client_sync_path']
    if client_sync_path[len(client_sync_path) - 1] != "/"
        let model_config['client_sync_path'] = client_sync_path . "/"
        let client_sync_path = model_config['client_sync_path']
    endif 
    if !has_key(model_config, 'client_secret_file') || model_config['client_secret_file'] == ""
        let model_config['client_secret_file'] = client_sync_path . ".vim-auto-sync-client.passwd.conf"
    endif
    if !has_key(model_config, 'client_log_file') || model_config['client_log_file'] == ""
        let model_config['client_log_file'] = client_sync_path . ".vim-auto-sync-client.log"
    endif
    if !has_key(model_config, 'client_result_file') || model_config['client_result_file'] == ""
        let model_config['client_result_file'] = client_sync_path . ".vim-auto-sync-client.result"
    endif
    if !has_key(model_config, 'client_pipo_file') || model_config['client_pipo_file'] == ""
        let model_config['client_pipo_file'] = client_sync_path . ".vim-auto-sync-client.pipo"
    endif
    " set default model_config
    let client_secret_file = model_config['client_secret_file']
    let client_log_file = model_config['client_log_file']
    let client_result_file = model_config['client_result_file']
    let client_pipo_file = model_config['client_pipo_file']

    " init client_secret_file
    if !filereadable(client_secret_file)
        " create local_secret_file to storage passwd
        let create_cmd = printf("touch %s && chmod 600 %s", client_secret_file, client_secret_file)
        execute '!' . create_cmd
    endif
    let passwd = model_config['passwd']
    let client_secret_file_content = [passwd]
    if writefile(client_secret_file_content, client_secret_file)
        echo "write file error"
    endif
    
    " init client_log_file
    if !filereadable(client_log_file)
        let cmd = printf("touch %s", client_log_file)
        execute '!' . cmd
    endif

    " init client_result_file
    if !filereadable(client_result_file)
        let cmd = printf("touch %s", client_result_file)
        execute '!' . cmd
    endif

    " init client_pipo_file
    if !filereadable(client_pipo_file)
        let cmd = printf("mkfifo %s", client_pipo_file)
        execute '!' . cmd
    endif

    let g:vim_sync_configs[a:model_name]  = model_config

    return 1

endfunction


function! SyncFile(timer) abort

    let g:vim_sync_configs = {
          \  'ci-console' : {
          \      'user' : 'root', 
          \      'ip' : '9.134.242.142', 
          \      'passwd' : 'It-is-just-rsync-passwd,-not-ssh-passwd', 
          \      'auto_sync_interval_ms' : 6000, 
          \      'client_sync_path' : '/Users/zhenhuli/tencent/ci-console', 
          \      'client_secret_file' : '/Users/zhenhuli/tencent/ci-console/.vim-auto-sync-client.passwd.conf', 
          \      'client_log_file' : "/Users/zhenhuli/tencent/ci-console/.vim-auto-sync-client.log", 
          \      'client_result_file' : "/Users/zhenhuli/tencent/ci-console/.vim-auto-sync-client.result", 
          \      'client_pipo_file' : "/Users/zhenhuli/tencent/ci-console/.vim-auto-sync-client.pipo", 
          \      'server_sync_path' : '/root', 
          \  }, 
          \  'vim-sync' : {
          \      'user' : 'root', 
          \      'ip' : '9.134.242.142', 
          \      'passwd' : 'It-is-just-rsync-passwd,-not-ssh-passwd', 
          \      'auto_sync_interval_ms' : 6000, 
          \      'client_sync_path' : '/Users/zhenhuli/tencent/vim-sync', 
          \      'client_secret_file' : '', 
          \      'client_log_file' : '', 
          \      'client_result_file' : '', 
          \      'client_pipo_file' : '', 
          \      'client_sync_execlude_file' : '',  
          \      'server_sync_path' : '/root/vim-sync', 
          \  }, 
          \  'cos-cloud-monitor' : {
          \      'user' : 'root', 
          \      'ip' : '9.134.25.215', 
          \      'passwd' : 'It-is-just-rsync-passwd', 
          \      'auto_sync_interval_ms' : 6000, 
          \      'client_sync_path' : '/Users/zhenhuli/tencent/cos_cloud_monitor', 
          \      'client_secret_file' : '', 
          \      'client_log_file' : '', 
          \      'client_result_file' : '', 
          \      'client_pipo_file' : '', 
          \      'client_sync_execlude_file' : '', 
          \      'server_sync_path' : '/root/cos_cloud_monitor', 
          \  }, 
          \  'cos_yy_export_data' : {
          \      'user' : 'root', 
          \      'ip' : '100.98.52.197', 
          \      'passwd' : 'It-is-just-rsync-passwd', 
          \      'auto_sync_interval_ms' : 6000, 
          \      'client_sync_path' : '/Users/zhenhuli/tencent/cos_yy_export_data/private_info/qcloud_cosop/cos_stat/script/cos_yy_export_data/', 
          \      'client_secret_file' : '', 
          \      'client_log_file' : '', 
          \      'client_result_file' : '', 
          \      'client_pipo_file' : '', 
          \      'client_sync_execlude_file' : '', 
          \      'server_sync_path' : '/usr/local/services/cos_yy_export_data-1.0/', 
          \  }, 
          \}
    

    let model_name = GetCurrentSyncModel()
    if model_name == ""
        return
    endif
    call SetModelDefaultConfig(model_name)
    let config = g:vim_sync_configs[model_name]

    let user = config['user']
    let ip = config['ip']
    let passwd = config['passwd']
    let auto_sync_interval_ms = config['auto_sync_interval_ms']
    let client_sync_path = config['client_sync_path']
    let client_secret_file = config['client_secret_file']
    let client_log_file = config['client_log_file']
    let client_result_file = config['client_result_file']
    let client_pipo_file = config['client_pipo_file']
    let execlude_file = ".vim-auto-sync-client*"

    " ==============rsync============
    let cmd = printf("rsync -avzP --exclude '%s' --delete %s  --progress --password-file=%s %s@%s::%s > %s ; echo 'done' > %s ", execlude_file,  client_sync_path, client_secret_file, user, ip, model_name, client_log_file, client_pipo_file)
    call asyncrun#run("!", "", cmd)
    let cmd = printf("cat %s", client_pipo_file)
    call system(cmd)
    call s:analysis_file_sync_status(client_log_file, client_result_file)
    " ==============rsync============
endfunction

function! GetFileSyncStatus() abort
    let model_name = GetCurrentSyncModel()
    " echo "[Vim-Sync-File-Plugin][debug]current sync model:" . model_name
    let config = g:vim_sync_configs[model_name]
    " echo "[Vim-Sync-File-Plugin][debug]current sync model config:" . json_encode(config)

    let client_sync_path = config['client_sync_path']
    if client_sync_path[len(client_sync_path) - 1] != "/"
        let client_sync_path = client_sync_path . "/"
    endif
    " echo "[Vim-Sync-File-Plugin][debug]client_sync_path:" . client_sync_path

    let self_path = expand("%:p")
    " echo "[Vim-Sync-File-Plugin][debug]self_path:" . self_path

    let result = s:get_file_mdtime(self_path)
    " echo "[Vim-Sync-File-Plugin][debug]mdtime:" . result

    let begin = len(client_sync_path)
    let tmp = self_path[begin:]
    " echo "[Vim-Sync-File-Plugin][debug]----:" . tmp

    let result = localtime()
    " echo result

    let client_result_file = config['client_result_file']
    " echo "[Vim-Sync-File-Plugin][debug]----:" . client_result_file
    let result = s:get_file_sync_status(client_result_file, tmp)
    echo result
    return result
endfunction


function! s:get_file_mdtime(file) abort

    if !filereadable(a:file)
        return 0
    endif
    return getftime(a:file)

endfunction


function! s:analysis_file_sync_status(log_filename, result_filename) abort

      let old_contents = readfile(a:result_filename)
      let old_analysis_result = {}
      if len(old_contents) == 0
          let old_analysis_result = {}
      else
        let old_analysis_result = json_decode(old_contents[0])
      endif

      " read log file and analysis
      let new_contents = readfile(a:log_filename)
      let i = 2
      let tmp = 0
      let file = ""
      while i < len(new_contents)
          let line = new_contents[i]
          let i = i + 1
          if line[len(line)-1] == "/"

              continue
          endif

          if tmp ==1
              let status = split(line, " ")
              if len(status) > 1 && len(file) > 0
                  let mdtime = s:get_file_mdtime(file)

                  let tmp = '0%'
                  for item in status
                      if item == '100%'
                          let tmp = '100%'
                      endif
                  endfor

                  let old_analysis_result[file] = {'status' : tmp, 'mdtime' : mdtime}
                  " echo file . "--" . json_encode(old_analysis_result[file])



              endif
          else 
              let file = line
          endif

          let tmp = tmp + 1
          if tmp == 2
              let tmp = 0
          endif

      endwhile

      let line = json_encode(old_analysis_result)
      let new_contents = [line]
      if writefile(new_contents, a:result_filename)
          echo "write file error"
      endif
endfunction

function! s:get_file_sync_status(result_filename, filename) abort
      " echo "[Vim-Sync-File-Plugin][debug]:" . a:result_filename . "-->" . a:filename
      let result = "Sync"
      if !filereadable(a:result_filename)
          return result . " ⌨  " 
      endif
      let contents = readfile(a:result_filename)

      let file_mdtime = s:get_file_mdtime(a:filename)
      let loacl_time = localtime()

      if len(contents) == 0
          return result . " ⌨  " 
      endif
      let content = contents[0]
      let files = json_decode(content)

      if &modified == 1 
          return result . " ⓘ "

      endif

      if has_key(files, a:filename)
          let sync_info = files[a:filename]
          " echo json_encode(sync_info)
          let status = sync_info['status']
          let mdtime = sync_info['mdtime']

          if file_mdtime > mdtime
              return result . " ↑ "
          endif
          if status == "100%" || status == "100"
              return result . " ♥ "
          endif
      endif

      return result . " ✖ "
endfunction



command! -nargs=0 SyncFile call SyncFile(1)
command! -nargs=0 GetFileStatus call GetFileSyncStatus()
"
"let asyncTimer = timer_start(6000, 'SyncFile', {'repeat': -1})
" autocmd BufWritePost * :call SyncFile(1)
