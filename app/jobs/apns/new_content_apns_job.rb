class NewContentApnsJob < Struct.new(:device_token, :link_preview_id)
  def self.send(device_token, card_id)
    Delayed::Job.enqueue new(device_token, card_id)
  end

  def perform
    return nil unless link_preview = LinkPreview.find_by(id: link_preview_id)
    ApnsNotification.new.notify_new_content_card(
      device_token, link_preview.id, link_preview.notification_message
    )
  end

  def queue_name
    'apns_notification'
  end
  
  def self.queue_name
    'apns_notification'
  end
end
