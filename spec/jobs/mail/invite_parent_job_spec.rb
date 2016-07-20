require 'rails_helper'
require 'mandrill_mailer/offline'

describe InviteParentJob do
  let!(:user){create(:user)}
  let!(:secondary_guardian){create(:user, family: user.family)}
  let(:invite_parent_job){InviteParentJob.new(secondary_guardian.id, user.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ invite_parent_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe ".send" do
    it "should send email to user via delayed_job" do
      expect{ InviteParentJob.send(secondary_guardian.id, user.id) }.to change(Delayed::Job.where(queue: 'registration_email'), :count).by(1)
    end
  end
end
