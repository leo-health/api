app_dir = "/app"
 
working_directory app_dir
 
pid "#{app_dir}/tmp/unicorn.pid"
 
stderr_path "/var/log/unicorn.stderr.log"
stdout_path "/var/log/unicorn.stdout.log"
 
worker_processes 1
listen "/app/tmp/unicorn.sock", :backlog => 64
timeout 30