require'rails_helper'
require 'mandrill_mailer/offline'

describe InternalMailer do
  before :each do
    MandrillMailer.deliveries.clear
  end

  describe "#error" do
    it "should send the error notification" do
      InternalMailer.sync_service_error("subject", "message").deliver
      email = MandrillMailer::deliveries.detect
      expect(email).to_not be_nil
    end
  end
end
