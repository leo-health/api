class NewContentApnsJob < Struct.new(:device_token, :card_id, :notification_message)
  def self.send(device_token:, card_id:, notification_message:)
    Delayed::Job.enqueue new(device_token, card_id, notification_message)
  end

  def perform
    ApnsNotification.new.notify_new_content_card(
      device_token, card_id, notification_message
    )
  end

  def queue_name
    'apns_notification'
  end
end
