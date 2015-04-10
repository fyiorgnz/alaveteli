# 8 workers and 1 master
worker_processes(8)

preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen ENV['UNICORN_SOCKET_PATH'], backlog: 2048
