app_dir = "/app"
 
working_directory app_dir
 
pid "/tmp/unicorn.pid"
 
stderr_path "/var/log/unicorn.stderr.log"
stdout_path "/var/log/unicorn.stdout.log"
 
worker_processes 1
listen "/tmp/unicorn.sock", :backlog => 64
timeout 30