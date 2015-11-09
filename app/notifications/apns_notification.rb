class ApnsNotification
  def initialize
    @pusher = Grocer.pusher(
        certificate: Rails.root.join('certificate.pem'),
        passphrase:  "catfood",
        gateway:     APNS_CONFIG['gateway'],
        retries:     3
    )
  end

  def send_hello_notification
    hello_notification = Grocer::Notification.new(
        device_token:      "63760a125ffeb4cc50f3e91f4a1ff609c4fb4df65aa4dd1453660d015cdff32e",
        alert:             "Hello!",
        custom:            { url_host: "conversation" },
        badge:             42,
        category:          "a category",         # optional; used for custom notification actions
        sound:             "siren.aiff",         # optional
        expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        identifier:        1234,                 # optional; must be an integer
        content_available: true                  # optional; any truthy value will set 'content-available' to 1
    )
    pusher.push(hello_notification)
  end

  private

  attr_reader :pusher
end
