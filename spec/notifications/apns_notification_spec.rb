require'rails_helper'
require 'timeout'

describe ApnsNotification do
  before do
    @server = Grocer.server(port: 2195)
    @server.accept
  end

  after do
    @server.close
  end

  describe "#send_hello_notification" do
    it "should send notification to user's device" do
      ApnsNotification.new.send_hello_notification
      Timeout.timeout(3) {
        notification = @server.notifications.pop # blocking
        expect(notification.alert).to eq("Hello!")
      }
    end
  end
end
