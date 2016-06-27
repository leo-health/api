require 'rails_helper'
require 'mandrill_mailer/offline'

describe TwoDayAppointmentReminderJob do
  let(:user){ create(:user) }
  let(:appointment){ create(:appointment, booked_by: user)}
  let!(:two_day_appointment_reminder_job){TwoDayAppointmentReminderJob.new(user.id, appointment.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ two_day_appointment_reminder_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ TwoDayAppointmentReminderJob.send(user.id, appointment.id) }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
