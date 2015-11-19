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
        certificate: Rails.root.join('certificate.pem'),
        passphrase:  "catfood", # need to replace it by env variable here
        gateway:     "gateway", # need to replace it by env variable here
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

  private

  attr_reader :pusher
end
