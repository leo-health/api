require'rails_helper'
require 'mandrill_mailer/offline'

describe UserMailer do
  describe "Trial" do
    let!(:user){create(:user, email: "test@leohealth.com")}

    before do
      MandrillMailer.deliveries.clear
    end

    it "should sent the user a trial email" do
      UserMailer.trial(user).deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'trial' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end
end
