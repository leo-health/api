require "rails_helper"
describe "GenerateUserReferralCards" do
  before do
    10.times{create(:user, :guardian)}
    create(:link_preview, :referral)
  end

  describe ".update_or_create_referral_user_link_preview" do
    it "creates a single user_link_preview" do
      user = User.first
      expect(UserLinkPreview.count).to eq(0)
      GenerateUserReferralCards.new.update_or_create_referral_user_link_preview(user)
      expect(UserLinkPreview.count).to eq(1)
      expect(UserLinkPreview.first.owner).to eq(user)
      expect(UserLinkPreview.first.user).to eq(user)
      expect(UserLinkPreview.first.link_preview.category.to_sym).to eq(:referral)
      expect(UserLinkPreview.first.published?).to eq(true)
    end
  end

  describe ".update_or_create_referral_user_link_preview_for_all_guardians" do
    it "" do
      expect(UserLinkPreview.count).to eq(0)
      GenerateUserReferralCards.new.update_or_create_referral_user_link_preview_for_all_guardians
      expect(
        UserLinkPreview.all.order(:user_id).map(&:published?)
      ).to eq(User.guardians.count.times.map{true})
    end
  end
end
