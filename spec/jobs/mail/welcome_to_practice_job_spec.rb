require 'rails_helper'
require 'mandrill_mailer/offline'

describe WelcomeToPracticeJob do
  let(:user){create(:user)}
  let(:welcome_to_practice_job){WelcomeToPracticeJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ welcome_to_practice_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ WelcomeToPracticeJob.send(user.id) }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
