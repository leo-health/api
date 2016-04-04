require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:patient_enrollments) }
    it{ is_expected.to have_one(:user) }

    it{ is_expected.to belong_to(:onboarding_group) }
    it{ is_expected.to belong_to(:insurance_plan) }
    it{ is_expected.to belong_to(:family) }
    it{ is_expected.to belong_to(:role) }
  end

  describe "ActiveModel validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:vendor_id) }

    context "if invited" do
      before { allow(subject).to receive(:invited?).and_return(true) }
      it { should validate_presence_of(:family) }
      it { should_not validate_presence_of(:password).on(:create) }
    end

    context "if not invited" do
      before { allow(subject).to receive(:invited?).and_return(false) }
      it { should_not validate_presence_of(:family) }
      it { should validate_presence_of(:password).on(:create) }
    end

    it { should allow_value('testuser@gmail.com').for(:email) }
    it { should validate_length_of(:password).is_at_least(8) }
    it { should validate_uniqueness_of(:vendor_id) }
  end
end
