require 'rails_helper'
require 'mandrill_mailer/offline'

describe UnaddressedConversationDigestJob do
  let!(:user){create(:user)}
  let!(:unaddressed_conversations_digest_job){UnaddressedConversationDigestJob.new(user.id, 1, "open")}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ unaddressed_conversations_digest_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ UnaddressedConversationDigestJob.send(user.id, 1, 'open') }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
