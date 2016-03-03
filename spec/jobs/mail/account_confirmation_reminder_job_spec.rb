require 'rails_helper'
require 'mandrill_mailer/offline'

describe AccountConfirmationReminderJob do
  let!(:user){create(:user)}
  let!(:account_confirmation_reminder_job){ AccountConfirmationReminderJob.new(user.id) }

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ account_confirmation_reminder_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ AccountConfirmationReminderJob.send(user.id) }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
