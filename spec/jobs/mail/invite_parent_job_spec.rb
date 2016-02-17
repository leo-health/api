require 'rails_helper'
require 'mandrill_mailer/offline'

describe InviteParentJob do
  let!(:user){create(:user)}
  let!(:enrollment){create(:enrollment)}
  let(:invite_parent_job){InviteParentJob.new(user.id, enrollment.id)}

  describe "#perform" do
    it "should send the email via mandrill mailer" do
      expect{ invite_parent_job.perform }.to change(MandrillMailer::deliveries, :count).by(1)
    end
  end

  describe ".send" do
    it "should send email to user via delayed_job" do
      expect{ InviteParentJob.send(enrollment.id, user.id) }.to change(Delayed::Job, :count).by(1)
    end
  end
end
