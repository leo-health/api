require 'rails_helper'
require 'mandrill_mailer/offline'

describe TwoDayAppointmentReminderJob do
  before (:each) do
    MandrillMailer.deliveries.clear
  end

  context "complete user" do
    let(:complete_user){ create(:user) }
    let(:appointment){ create(:appointment, booked_by: complete_user)}
    let!(:two_day_appointment_reminder_job){TwoDayAppointmentReminderJob.new(complete_user.id, appointment.id)}

    describe "#perform" do
      it "should send the email via mandrill mailer" do
        expect{ two_day_appointment_reminder_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
        expect( MandrillMailer::deliveries.first.template_name ).to eq("Leo - 48 Hour Appt Reminder - Registered")
      end
    end

    describe "#send" do
      it "should send email to user via delayed_job" do
        expect{ TwoDayAppointmentReminderJob.send(complete_user.id, appointment.id) }
          .to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
      end
    end
  end

  context "incomplete and from athena user" do
    let(:athena_group){ create(:onboarding_group, :generated_from_athena) }
    let(:incomplete_user){create(:user, :incomplete, onboarding_group: athena_group) }
    let(:appointment){ create(:appointment)}
    let!(:two_day_appointment_reminder_job){TwoDayAppointmentReminderJob.new(incomplete_user.id, appointment.id)}

    describe "#perform" do
      it "should send the email via mandrill mailer" do
        expect{ two_day_appointment_reminder_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
        expect( MandrillMailer::deliveries.first.template_name ).to eq("Leo - 48 Hour Appt Reminder - NOT registered")
      end
    end

    describe "#send" do
      it "should send email to user via delayed_job" do
        expect{ TwoDayAppointmentReminderJob.send(incomplete_user.id, appointment.id) }
          .to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
      end
    end
  end
end
