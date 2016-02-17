require 'rails_helper'
require 'mandrill_mailer/offline'

describe RemindScheduleAppointmentJob do
  let!(:user){create(:user)}
  let!(:remind_schedule_appointment_job){RemindScheduleAppointmentJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ remind_schedule_appointment_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ RemindScheduleAppointmentJob.send(user.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
