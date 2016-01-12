require 'rails_helper'

RSpec.describe Patient, type: :model do
 let!(:customer_service) { create(:user, :customer_service) }
 let!(:bot){ create(:user, :bot)}
 let!(:patient) { create(:patient) }

 describe 'relations' do
   it{ is_expected.to belong_to(:family) }
   it{ is_expected.to belong_to(:role) }
   it{ is_expected.to have_many(:appointments) }
   it{ is_expected.to have_many(:medications) }
   it{ is_expected.to have_many(:photos) }
   it{ is_expected.to have_many(:vaccines) }
   it{ is_expected.to have_many(:vitals) }
   it{ is_expected.to have_many(:insurances) }
   it{ is_expected.to have_many(:avatars) }
 end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:birth_date) }
    it { is_expected.to validate_presence_of(:sex) }
    it { is_expected.to validate_presence_of(:family) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe 'callbacks' do
    describe "after_commit" do
      it { expect(patient).to callback(:upgrade_guardian!).after(:commit).on(:create) }

      it { expect(patient).to callback(:notify_guardian).after(:commit).on(:create) }

      it "should notify guardian about child's sign up" do
        expect( patient.family.conversation.messages.last.body ).to eq( "#{patient.first_name.capitalize} has been enrolled successfully" )
      end
    end
  end

  describe '#current_avatar' do
    let!(:old_avatar){ create(:avatar, owner: patient)}
    let!(:current_avatar){ create(:avatar, owner: patient)}

    it 'should return the current_avatar' do
      expect( patient.current_avatar ).to eq(current_avatar)
    end
  end
end
