require 'rails_helper'
require 'mandrill_mailer/offline'

describe PrimaryGuardianApproveInvitationJob do
  let!(:user){create(:user)}
  let!(:primary_guardian_approve_invitation_job){PrimaryGuardianApproveInvitationJob.new(user.id, "token")}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ primary_guardian_approve_invitation_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe "#send" do
    it "should send email to user via delayed_job" do
      expect{ PrimaryGuardianApproveInvitationJob.send(user.id, "token") }.to change(Delayed::Job, :count).by(1)
    end
  end
end
