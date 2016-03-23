require'rails_helper'
require 'mandrill_mailer/offline'

describe SyncServiceMailer do
  before :each do
    MandrillMailer.deliveries.clear
  end

  describe "#error" do
    it "should send the error notification" do
      SyncServiceMailer.error("subject", "message").deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Failed Sync Notification'
      end
      expect(email).to_not be_nil
    end
  end
end
