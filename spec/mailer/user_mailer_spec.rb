require'rails_helper'
require 'mandrill_mailer/offline'

describe UserMailer do
  let(:user){build(:user, email: "test@leohealth.com")}

  before :each do
    MandrillMailer.deliveries.clear
  end

  describe "confirmation_instructions" do
    it "should send the user a confirmation_instructions email" do
      UserMailer.confirmation_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'Leo - Sign Up - Confirmation' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end

  describe "reset_password_instructions" do
    it "should send the user a reset_password_instructions email" do
      UserMailer.reset_password_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'Leo - Password - Reset Password' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end

  describe "invite secondary parent" do
    let(:enrollment){ build(:enrollment) }
    it "should send the secondary parent a invite" do
      UserMailer.invite_secondary_parent(enrollment, user).deliver
      email = MandrillMailer::deliveries.detect { |mail| mail.template_name == 'Leo - Invite User' && mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" } }
      expect(email).to_not be_nil
    end
  end
end
