require 'rails_helper'

RSpec.describe OnboardingGroup, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:enrollments) }
    it{ is_expected.to have_many(:users) }
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:group_name) }
  end

  describe "#invited_secondary_guardian?" do
    let(:onboarding_group){ create(:onboarding_group) }

    it "should return true if it is a invited secondary guardian group" do
      expect(onboarding_group.invited_secondary_guardian?).to eq(true)
    end
  end
end
