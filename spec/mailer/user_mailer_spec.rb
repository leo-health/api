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

  describe "#five_day_appointment_reminder" do
    it "should send the user an reminder of the appointment 5 days prior to the scheduled visit" do
      UserMailer.five_day_appointment_reminder(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Five Day Appointment Reminder' &&
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

  describe "#same_day_appointment_reminder" do
    it "should send the user an reminder of the appointment on same day" do
      UserMailer.same_day_appointment_reminder(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Same Day Appointment Reminder' &&
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

  describe "#patient_birthday" do
    it "should send the guardian a email" do
      UserMailer.patient_birthday(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Patient Happy Birthday' &&
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

  describe "#account_confirmation_reminder" do
    it "should send user a reminder" do
      UserMailer.account_confirmation_reminder(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Account Confirmation Reminder' &&
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

  describe "#unaddressed_conversations_digest" do
    it "should notify staff the number of unaddressed escalated conversations" do
      UserMailer.unaddressed_conversations_digest(user, 5, :escalated).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Unaddressed Conversations Digest' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#batched_message" do
    it "should notify guardian of new messages" do
      UserMailer.batched_messages(user, "haha").deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Message Digest' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end
end
