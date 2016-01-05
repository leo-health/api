require 'rails_helper'
require 'mandrill_mailer/offline'

describe PasswordChangeConfirmationJob do
  let!(:user){create(:user)}
  let!(:password_change_confirmation_job){PasswordChangeConfirmationJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ password_change_confirmation_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ PasswordChangeConfirmationJob.send(user.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
