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

  describe "#notify_new_message" do
    let(:device_token){"devicetoken"}

    it "should send new message reminder to user's device" do
      ApnsNotification.new.notify_new_message(device_token)
      Timeout.timeout(3) {
        notification = @server.notifications.pop
        expect(notification.alert).to eq("You have a new message")
      }
    end
  end
end
