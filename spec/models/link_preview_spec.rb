require 'rails_helper'

describe "LinkPreview" do
  let!(:user1){ create(:user, :guardian) }
  let!(:session1){ user1.sessions.create(device_type: "iPhone 6", device_token: "user1_device_token")}
  let!(:user2){ create(:user, :guardian) }
  let!(:session2){ user2.sessions.create(device_type: "iPhone 6", device_token: "user2_device_token")}
  let!(:link_preview){ create(:link_preview, :notification) }

  describe ".send_to" do
    context "single guardian" do
      it "creates and publishes UserLinkPreview" do
        user_link_previews = link_preview.send_to(user1)
        expect(user_link_previews.count).to eq(1)
        expect(user_link_previews.first.published?).to be(true)
        expect(Delayed::Job.where(queue: NewContentApnsJob.queue_name).count).to eq(1)
      end
    end

    context "multiple guardians" do
      it "creates many UserLinkPreviews" do
        user_link_previews = link_preview.send_to([user1, user2])
        expect(user_link_previews.count).to eq(2)
        expect(user_link_previews.first.published?).to be(true)
        expect(user_link_previews.second.published?).to be(true)
        expect(Delayed::Job.where(queue: NewContentApnsJob.queue_name).count).to eq(2)
      end
    end

    context "with passed dismissed_at" do
      it "creates a UserLinkPreview that is not published" do
        user_link_previews = link_preview.send_to(user1, dismissed_at: Time.now)
        expect(user_link_previews.count).to eq(1)
        expect(user_link_previews.first.published?).to be(false)
        expect(Delayed::Job.where(queue: NewContentApnsJob.queue_name).count).to eq(0)
      end
    end
  end

  describe ".send_to_with_30_day_expiry" do
    it "creates a UserLinkPreview with dismissed_at 30 days from now" do
      Timecop.freeze
      user_link_previews = link_preview.send_to_with_30_day_expiry(user1)
      expect(user_link_previews.count).to eq(1)
      expect(user_link_previews.first.dismissed_at).to eq(30.days.from_now)
      expect(user_link_previews.first.published?).to be(true)
      expect(Delayed::Job.where(queue: NewContentApnsJob.queue_name).count).to eq(1)
    end
  end
end
