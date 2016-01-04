require 'rails_helper'
require 'mandrill_mailer/offline'

describe FiveDayAppointmentReminderJob do
  let!(:user){create(:user)}
  let!(:five_day_appointment_reminder_job){FiveDayAppointmentReminderJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ five_day_appointment_reminder_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ FiveDayAppointmentReminderJob.send(user.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
