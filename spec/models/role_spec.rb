require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'relations' do
    it{ is_expected.to have_many(:users) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'scope' do
    context "staff_roles" do
      let!(:financial){ create(:role, :financial) }
      let!(:clinical_support){ create(:role, :clinical_support) }
      let!(:customer_service){ create(:role, :customer_service) }
      let!(:clinical){ create(:role, :clinical) }
      let!(:operational){ create(:role, :operational) }

      it "should return all staff" do
        expect(Role.staff_roles).to match_array([financial, clinical_support, customer_service, clinical, operational])
      end
    end

    context "clinical_staff_roles" do
      let!(:clinical_support){ create(:role, :clinical_support) }
      let!(:customer_service){ create(:role, :customer_service) }
      let!(:clinical){ create(:role, :clinical) }

      it "should return all clinical staff roles" do
        expect(Role.clinical_staff_roles).to match_array([clinical_support, customer_service, clinical])
      end
    end

    context "guardian_roles" do
      let!(:guardian){ create(:role, :guardian) }

      it "should return the guardian roles" do
        expect(Role.guardian_roles).to eq([guardian])
      end
    end
  end


  describe ".guardian" do
    let!(:guardian){ create(:role, :guardian) }

    it "should return the guardian role" do
      expect(Role.guardian).to eq(guardian)
    end
  end
end
