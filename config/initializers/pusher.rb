Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_KEY']
Pusher.secret = ENV['PUSHER_SECRET']
Pusher.logger = Rails.logger unless Rails.env.test?
unless Rails.env.test?
 Pusher.encrypted = true
end
