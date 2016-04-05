require 'rails_helper'
require 'mandrill_mailer/offline'

describe InternalInvitationEnrollmentNotificationJob do
  let(:user){ create(:user) }
  let!(:internal_invitation_enrollment_notification_job){InternalInvitationEnrollmentNotificationJob.new(user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ internal_invitation_enrollment_notification_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ InternalInvitationEnrollmentNotificationJob.send(user.id) }.to change(Delayed::Job.where(queue: 'notification_email'), :count).by(1)
    end
  end
end
