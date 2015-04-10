require 'sidekiq/web'

run Rack::URLMap.new('/' => Sidekiq::Web)
