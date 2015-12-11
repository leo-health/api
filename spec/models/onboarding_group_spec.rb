require 'rails_helper'

RSpec.describe OnboardingGroup, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:enrollments) }
    it{ is_expected.to have_many(:users) }
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:group_name) }
  end
end
