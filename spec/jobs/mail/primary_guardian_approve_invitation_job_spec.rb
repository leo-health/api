require 'rails_helper'
require 'mandrill_mailer/offline'

describe PrimaryGuardianApproveInvitationJob do
  let(:user){ create :user }
  let(:enrollment){ create(:enrollment, family: user.family)}
  let(:primary_guardian_approve_invitation_job){PrimaryGuardianApproveInvitationJob.new(user.id, enrollment.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ primary_guardian_approve_invitation_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe ".send" do
    it "should send email to user via delayed_job, and send account confirmation email to invited parent" do
      expect{ PrimaryGuardianApproveInvitationJob.send(user.id, enrollment.id) }.to change(Delayed::Job.where(queue: 'registration_email'), :count).by(2)
    end
  end
end
