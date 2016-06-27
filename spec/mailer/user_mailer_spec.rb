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
        mail.template_name == 'Leo - Sign Up Confirmation' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#reset_password_instructions" do
    it "should send the user a reset_password_instructions email" do
      UserMailer.reset_password_instructions(user, "token").deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Password Reset' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#invite_secondary_parent" do
    let(:secondary_guardian){ build(:user, family: user.family) }

    it "should send the secondary parent a invite" do
      UserMailer.invite_secondary_parent(secondary_guardian, user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Invite a Secondary Guardian' &&
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

  describe "#complete_user_two_day_appointment_reminder" do
    let(:appointment){ build :appointment }

    it "should send the user an reminder of the appointment on same day" do
      UserMailer.complete_user_two_day_appointment_reminder(user, appointment).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - 48 Hour Appt Reminder - Registered' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#incomplete_user_two_day_appointment_reminder" do
    let(:appointment){ build :appointment }
    let(:user){ build :user, email: "test@leohealth.com", complete_status: nil }

    it "should send the user an reminder of the appointment on same day" do
      UserMailer.incomplete_user_two_day_appointment_reminder(user, appointment).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - 48 Hour Appt Reminder - NOT registered' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#patient_birthday" do
    let(:patient){ build :patient }

    it "should send the guardian a email" do
      UserMailer.patient_birthday(user, patient).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Patient Birthday' &&
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
        mail.template_name == 'Leo - Password Changed Confirmation' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#notify_escalated_conversation" do
    it "should send user a email when a conversation escalated to the user" do
      UserMailer.notify_escalated_conversation(user).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo Provider - Case Assigned' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#unaddressed_conversations_digest" do
    it "should notify staff the number of unaddressed escalated conversations" do
      UserMailer.unaddressed_conversations_digest(user, 5).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo Provider - Unresolved Assigned Cases' &&
          mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#remind_unread_messages" do
    let(:message){ build :message }

    it "should notify guardian of read message from staff" do
      UserMailer.remind_unread_messages(user, message).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Unread Message' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end

  describe "#primary_guardian_approve_invitation" do
    let(:secondary_guardian){ build(:user, family: user.family) }

    it "should ask primary guardian for approval of pending invitation" do
      UserMailer.primary_guardian_approve_invitation(user, secondary_guardian).deliver
      email = MandrillMailer::deliveries.detect do |mail|
        mail.template_name == 'Leo - Secondary Guardian Confirmation' &&
            mail.message['to'].any? { |to| to[:email] = "test@leohealth.com" }
      end
      expect(email).to_not be_nil
    end
  end
end
