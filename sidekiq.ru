require 'bundler'
Bundler.require(:default, :production)
require 'sidekiq/web'

run Rack::URLMap.new('/' => Sidekiq::Web)
