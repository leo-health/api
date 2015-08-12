require 'rails_helper'
require 'mandrill_mailer/offline'

describe ResetPasswordJob do
  let(:user){create(:user)}
  let!(:reset_password_job){ResetPasswordJob.new(user.id, "test_token")}

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ reset_password_job.send }.to change(Delayed::Job, :count).by(1)
    end
  end

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ reset_password_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end
end
