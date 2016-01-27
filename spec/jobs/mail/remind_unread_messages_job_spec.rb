require 'rails_helper'
require 'mandrill_mailer/offline'

describe RemindUnreadMessagesJob do
  let!(:user){create(:user)}
  let!(:message){ create(:message) }
  let!(:remind_unread_messages_job){ RemindUnreadMessagesJob.new(user.id, message.id) }

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ remind_unread_messages_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ RemindUnreadMessagesJob.send(user.id, message.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
