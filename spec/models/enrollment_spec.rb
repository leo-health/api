require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:patient_enrollments) }

    it{ is_expected.to belong_to(:onboarding_group) }
    it{ is_expected.to belong_to(:insurance_plan) }
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:email) }
    it { should allow_value('testuser@gmail.com').for(:email) }
    it { should validate_length_of(:password).is_at_least(8) }
  end
end
