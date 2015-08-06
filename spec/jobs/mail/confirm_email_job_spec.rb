require 'rails_helper'
require 'mandrill_mailer/offline'

describe ConfirmEmailJob do
  let(:user){create(:user)}
  let!(:confirm_email_job){ConfirmEmailJob.new(user.id, "test_token")}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ confirm_email_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ confirm_email_job.send }.to change(Delayed::Job, :count).by(1)
    end
  end
end
