require 'athena_health_api'

AthenaHealthAPI.configure do |config|
  if Rails.env.production?
    config.min_request_interval = (24.0/500000).hours
  else
    config.min_request_interval = (24.0/50000).hours
  end

  config.num_workers = 4

  #use delayed job logger
  config.logger = Delayed::Worker.logger
end
