class ApnsNotification
  def initialize
    # development:
    #     gateway: "gateway.sandbox.push.apple.com"
    #     passphrase:  "catfood"
    # test:
    #     gateway: "localhost"
    #     passphrase:  "catfood"
    # production:
    #     gateway: "gateway.push.apple.com"
    #     passphrase:  "catfood"

    @pusher = Grocer.pusher(
        certificate: ENV['APNS_CERTIFICATE'],
        passphrase:  ENV['APNS_CERTIFICATE_PASSWORD’], 
        gateway:     ENV['APNS_CERTIFICATE_GATEWAY’], 
        retries:     3
    )
  end

  def send_hello_notification
    hello_notification = Grocer::Notification.new(
        device_token:      "63760a125ffeb4cc50f3e91f4a1ff609c4fb4df65aa4dd1453660d015cdff32e",
        alert:             "Hello!",
        custom:            { url_host: "conversation", url_path: 0 },
        badge:             42,
        sound:             "siren.aiff",         # optional
        expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        content_available: false                  # optional; any truthy value will set 'content-available' to 1
    )
    pusher.push(hello_notification)
  end

  def notify_new_message(device_token)
    new_message_notification = Grocer::Notification.new(
      device_token:      device_token,
      alert:             "You have a new message",
      badge:             1,
      category:          "a category",         # optional; used for custom notification actions
      sound:             "siren.aiff",         # optional
      expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
      identifier:        1234,                 # optional; must be an integer
      content_available: true                  # optional; any truthy value will set 'content-available' to 1
    )
    pusher.push(new_message_notification)
  end

  private

  attr_reader :pusher
end
