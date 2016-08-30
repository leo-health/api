require 'rails_helper'

describe "UserLinkPreview" do
  describe "on create" do
    it "creates an APNS job" do
      family = create(:family_with_members)
      guardian = family.guardians.first
      link = create(:link_preview, :milestone_content, age_of_patient_in_months: 1)
      guardian.sessions.create(device_token: "token")

      expect { UserLinkPreview.create(
        user: guardian,
        owner: family.patients.first,
        link_preview: link
      )}.to change {
        Delayed::Job.where(queue: :apns_notification).count
      }.by(1)
    end
  end
end
