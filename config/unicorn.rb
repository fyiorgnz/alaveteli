app_dir = File.expand_path("../..", __FILE__)
log_dir = (ENV['UNICORN_LOGDIR'] || "#{app_dir}/log")
pid_dir = (ENV['UNICORN_PIDDIR'] || "#{app_dir}")
working_directory app_dir

# 8 workers and 1 master
worker_processes(8)

preload_app true

# Restart any workers that haven't responded in 90 or UNICORN_TIMEOUT seconds
timeout (ENV['UNICORN_TIMEOUT'] || 90).to_i

# Listen on a Unix data socket
listen ENV['UNICORN_SOCKET_PATH'], backlog: 2048

# Logging
stderr_path "#{log_dir}/unicorn.stderr.log"
stdout_path "#{log_dir}/unicorn.stdout.log"

# PID File
pid "#{pid_dir}/unicorn.pid"

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

