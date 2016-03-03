require 'rails_helper'
require 'mandrill_mailer/offline'

describe NotifyEscalatedConversationJob do
  let!(:user){create(:user)}
  let!(:notify_escalated_conversation_job){NotifyEscalatedConversationJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ notify_escalated_conversation_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe ".send" do
    it "should send email to user via delayed_job" do
      expect{ NotifyEscalatedConversationJob.send(user.id) }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
