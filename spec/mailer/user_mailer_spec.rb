require'rails_helper'
require 'mandrill_mailer/offline'

describe UserMailer do
  before :each do
    MandrillMailer.deliveries.clear
  end

  describe "confirmation_instructions" do
    let!(:user){create(:user, email: "test@leohealth.com")}

    it "should sent the user a confirmation_instructions email" do
      UserMailer.confirmation_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'Leo email confirmation' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end

  describe "reset_password_instructions" do
    let!(:user){create(:user, email: "test@leohealth.com")}

    it "should sent the user a reset_password_instructions email" do
      UserMailer.reset_password_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'Leo reset password' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end
end
