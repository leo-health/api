require 'athena_health_api'

AthenaHealthAPI.configure do |config|
  config.min_request_interval = (0.2).seconds
end
