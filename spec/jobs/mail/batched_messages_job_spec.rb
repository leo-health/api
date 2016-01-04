require 'rails_helper'
require 'mandrill_mailer/offline'

describe BatchedMessagesJob do
  let!(:user){create(:user)}
  let!(:batched_messages_job){BatchedMessagesJob.new(user.id, 'body')}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ batched_messages_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ BatchedMessagesJob.send(user.id, 'body') }.to change(Delayed::Job, :count).by(1)
    end
  end
end
