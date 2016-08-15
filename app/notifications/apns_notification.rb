class ApnsNotification
  def initialize
    @pusher = Grocer.pusher(
        certificate: ENV['APNS_CERTIFICATE'],
        passphrase:  ENV['APNS_CERTIFICATE_PASSWORD'],
        gateway:     ENV['APNS_CERTIFICATE_GATEWAY'],
        retries:     3
    )
  end

  def notify_new_message(device_token)
    new_message_notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             "You have a new message",
      custom:            { url_host: "conversation", url_path: 0 },
      badge:             1,
      sound:             "siren.aiff",         # optional
      expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
      content_available: false
    )
    pusher.push(new_message_notification)
  end

  def notify_new_visit_content(device_token, deep_link_path, notification_message)
    new_content_notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             notification_message,
      custom:            { url_host: "feed", url_path: deep_link_path },
      badge:             1,
      sound:             "siren.aiff",         # optional
      expiry:            Time.now + 60*60*24,     # optional; 0 is default, meaning the message is not stored
      content_available: false
    )
    pusher.push(new_content_notification)
  end

  private

  attr_reader :pusher
end
