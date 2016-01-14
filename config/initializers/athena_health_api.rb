require 'athena_health_api'

AthenaHealthAPI.configure do |config|
  config.min_request_interval = 5.seconds
end
