class NewMessageApnsJob < Struct.new(:device_token)

  def self.send(device_token)
    Delayed::Job.enqueue new(device_token)
  end

  def perform
    ApnsNotification.new.notify_new_message(device_token)
  end

  def queue_name
    'apns_notification'
  end
end
