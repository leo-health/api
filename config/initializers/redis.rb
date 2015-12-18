if Rails.env.test?
  $redis = Redis.new
else
  $redis = Redis.new(:host => 'localhost', :port => 6379)
end
