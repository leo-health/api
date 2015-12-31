require 'rails_helper'
require 'mandrill_mailer/offline'

describe PatientBirthdayJob do
  let!(:user){create(:user)}
  let!(:patient_birthday_job){PatientBirthdayJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ patient_birthday_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ PatientBirthdayJob.send(user.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
