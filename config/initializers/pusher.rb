#TODO save keys on server
if Rails.env.test?
  Pusher.app_id = "MY_TEST_ID"
  Pusher.key    = "MY_TEST_KEY"
  Pusher.secret = "MY_TEST_SECRET"
else
  Pusher.app_id = '131452'
  Pusher.key = '218006d766a6d76e8672'
  Pusher.secret = '988ccf7344c190c723fc'
  Pusher.logger = Rails.logger
end
