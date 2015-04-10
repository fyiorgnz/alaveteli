require 'bundler'
Bundle.require(:default, :production)
require 'sidekiq/web'

run Rack::URLMap.new('/' => Sidekiq::Web)
