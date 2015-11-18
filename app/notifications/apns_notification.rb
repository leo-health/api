class ApnsNotification
  def initialize
    @pusher = Grocer.pusher(
        certificate: "/path/to/cert.pem",      # required
        passphrase:  "",                       # optional
        gateway:     "gateway.push.apple.com", # optional
        port:        2195,                     # optional
        retries:     3                         # optional
    )
  end

  def send_hello_notification
    hello_notification = Grocer::Notification.new(
        device_token:      "fe15a27d5df3c34778defb1f4f3880265cc52c0c047682223be59fb68500a9a2",
        alert:             "Hello!",
        badge:             42,
        category:          "a category",         # optional; used for custom notification actions
        sound:             "siren.aiff",         # optional
        expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        identifier:        1234,                 # optional; must be an integer
        content_available: true                  # optional; any truthy value will set 'content-available' to 1
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
