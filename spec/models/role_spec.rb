require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'relations' do
    it{ is_expected.to have_many(:users) }
    it{ is_expected.to have_many(:patients) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '.staff' do
    let!(:financial){ create(:role, :financial) }
    let!(:clinical_support){ create(:role, :clinical_support) }
    let!(:customer_service){ create(:role, :customer_service) }
    let!(:clinical){ create(:role, :clinical) }
    let!(:operational){ create(:role, :operational) }

    it "should return all staff" do
      expect(Role.staff).to eq([financial, clinical_support, customer_service, clinical, operational])
    end
  end

  describe '.clinical_staff' do
    let!(:clinical_support){ create(:role, :clinical_support) }
    let!(:customer_service){ create(:role, :customer_service) }
    let!(:clinical){ create(:role, :clinical) }

    it "should return all clinical staff roles" do
      expect(Role.clinical_staff).to eq([clinical_support, customer_service, clinical])
    end
  end

  describe '.guardian' do
    let!(:guardian){ create(:role, :guardian) }

    it "should return the guardian role" do
      expect(Role.guardian).to eq(guardian)
    end
  end
end
