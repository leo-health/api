require 'rails_helper'
require 'mandrill_mailer/offline'

describe SyncServiceErrorJob do
  let!(:sync_service_error_job){ SyncServiceErrorJob.new('subject', 'message') }

  describe ".send" do
    it "should send email to admins" do
      expect{ SyncServiceErrorJob.send("subject", "message") }.to change(Delayed::Job.where(queue: 'sync_error_email'), :count).by(1)
    end
  end

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ sync_service_error_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end
end
