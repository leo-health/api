# if Rails.env.test?
#   $redis = Redis.new
# elsif Rails.env.development?
#   $redis = Redis.new(:host => 'localhost', :port => 6379)
# elsif Rails.env.develop?
#   $redis = Redis.new(:host => 'redis-dev.leohealth.internal', :port => 6379)
# else
#   $redis = Redis.new(:host => 'notificationcache.fhtgid.0001.use1.cache.amazonaws.com', :port => 6379)
# end
$redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])

