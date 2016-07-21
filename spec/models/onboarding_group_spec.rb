require 'rails_helper'

RSpec.describe OnboardingGroup, type: :model do
  let(:primary_onboarding_group){ create(:onboarding_group) }
  let(:invited_onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
  let(:athena_onboarding_group){ create(:onboarding_group, :generated_from_athena) }

  describe "relations" do
    it{ is_expected.to have_many(:users) }
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:group_name) }
  end

  describe ".primary_guardian" do
    before do
      primary_onboarding_group
    end

    it "should return the primary guardian onboarding group" do
      expect( OnboardingGroup.primary_guardian ).to eq(primary_onboarding_group)
    end
  end

  describe ".invited_secondary_guardian" do
    before do
      invited_onboarding_group
    end

    it "should return the primary guardian onboarding group" do
      expect( OnboardingGroup.invited_secondary_guardian ).to eq(invited_onboarding_group)
    end
  end

  describe ".generated_from_athena" do
    before do
      athena_onboarding_group
    end

    it "should return the primary guardian onboarding group" do
      expect( OnboardingGroup.generated_from_athena ).to eq(athena_onboarding_group)
    end
  end

  describe "#primary_guardian?" do
    it "should return true if it is a invited secondary guardian group" do
      expect(primary_onboarding_group.primary_guardian?).to eq(true)
    end
  end

  describe "#invited_secondary_guardian?" do
    it "should return true if it is a invited secondary guardian group" do
      expect(invited_onboarding_group.invited_secondary_guardian?).to eq(true)
    end
  end

  describe "#generated_from_athena?" do
    it "should return true if it is a invited secondary guardian group" do
      expect(athena_onboarding_group.generated_from_athena?).to eq(true)
    end
  end
end
