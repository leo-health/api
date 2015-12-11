require'rails_helper'
require 'mandrill_mailer/offline'

describe UserMailer do
  let(:user){build(:user, email: "test@leohealth.com")}

  before :each do
    MandrillMailer.deliveries.clear
  end

  describe "#confirmation_instructions" do
    it "should send the user a confirmation_instructions email" do
      UserMailer.confirmation_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Sign Up - Confirmation' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#reset_password_instructions" do
    it "should send the user a reset_password_instructions email" do
      UserMailer.reset_password_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Password - Reset Password' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#invite_secondary_parent" do
    let(:enrollment){ build(:enrollment) }
    it "should send the secondary parent a invite" do
      UserMailer.invite_secondary_parent(enrollment, user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Invite User' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#welcome_to_practice" do
    it "should send the user a welcome email to practice" do
      UserMailer.welcome_to_pratice(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Welcome to Practice' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#remind_schedule_appointment" do
    it "send the user an reminder" do
      UserMailer.remind_schedule_appointment(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Remind Schedule Appointment' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#notify_new_messages" do
    it "should send user email when user received message" do
      UserMailer.notify_new_message(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Notify New Message' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#password_change_confirmation" do
    it "should send the user a email confirmation that they have successfully changed their password" do
      UserMailer.password_change_confirmation(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Password Changed' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#notify_escalated_conversation" do
    it "should send user a email when a conversation escalated to the user" do
      UserMailer.notify_escalated_conversation(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Escalated Conversation' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end
end
