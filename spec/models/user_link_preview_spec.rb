require 'rails_helper'

describe "UserLinkPreview" do
  describe "after commit" do
    let!(:family){create(:family_with_members)}
    let!(:guardian){family.guardians.first}
    let!(:family){create(:family_with_members)}
    let!(:link){create(:link_preview, :notification, :milestone_content,
      age_of_patient_in_months: 1,
    )}

    before do
      guardian.sessions.create(device_type: "iPhone 6", device_token: "token")
    end

    context "dismissed_at initialized as nil" do
      it "creates an APNS job if published" do
        expect { UserLinkPreview.create(
          user: guardian,
          owner: family.patients.first,
          link_preview: link,
          sends_push_notification_on_publish: true
        )}.to change {
          Delayed::Job.where(queue: NewContentApnsJob.queue_name).count
        }.by(1)
      end
    end

    context "dismissed_at initialized as past" do
      it "creates an APNS job if published" do
        expect { UserLinkPreview.create(
          user: guardian,
          owner: family.patients.first,
          link_preview: link,
          dismissed_at: 1.hour.ago,
          sends_push_notification_on_publish: true
        )}.to change {
          Delayed::Job.where(queue: NewContentApnsJob.queue_name).count
        }.by(0)
      end
    end

    context "dismissed_at changed from past to future" do
      it "creates an APNS job if published" do
        ulp = UserLinkPreview.create(
          user: guardian,
          owner: family.patients.first,
          link_preview: link,
          dismissed_at: 1.hour.ago,
          sends_push_notification_on_publish: true
        )

        expect{ ulp.update_attributes(dismissed_at: 1.hour.from_now) }.to change {
          Delayed::Job.where(queue: NewContentApnsJob.queue_name).count
        }.by(1)
      end
    end
  end
end
