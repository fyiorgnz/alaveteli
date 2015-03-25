# 8 workers and 1 master
worker_processes(8)

preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen '/data/fyi/sockets/unicorn.sock', backlog: 2048

