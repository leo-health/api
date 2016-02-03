require 'athena_health_api'

AthenaHealthAPI.configure do |config|
  if Rails.env.production?
    config.min_request_interval = (0.000002).seconds
  else
    config.min_request_interval = (0.2).seconds
  end
end
