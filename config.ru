# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put]
  end
end

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'production' && password == 'leohealth'
  end
end

if Rails.env.develop?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == 'develop' && password == 'leohealth'
  end
end

AnalyticsController.use Rack::Auth::Basic do |username, password|
  username == 'analytics' && password == 'leohealth'
end

run Rails.application
