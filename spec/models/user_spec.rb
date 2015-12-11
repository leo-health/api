require 'rails_helper'

describe User do
  let!(:customer_service){ create(:user, :customer_service) }

  describe "relations" do
    it{ is_expected.to belong_to(:family) }
    it{ is_expected.to belong_to(:role) }
    it{ is_expected.to belong_to(:practice) }
    it{ is_expected.to belong_to(:onboarding_group) }

    it{ is_expected.to have_one(:provider_profile).with_foreign_key('provider_id') }

    it{ is_expected.to have_many(:user_conversations) }
    it{ is_expected.to have_many(:conversations).through(:user_conversations) }
    it{ is_expected.to have_many(:read_receipts).with_foreign_key('reader_id') }
    it{ is_expected.to have_many(:escalation_notes).class_name('EscalationNote').with_foreign_key('escalated_to_id') }
    it{ is_expected.to have_many(:read_messages).class_name('Message').with_foreign_key('read_receipts') }
    it{ is_expected.to have_many(:sessions) }
    it{ is_expected.to have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id') }
    it{ is_expected.to have_many(:provider_appointments).class_name('Appointment').with_foreign_key('provider_id') }
  end

  describe "validations" do
    subject { FactoryGirl.build(:user) }

    it { is_expected.to validate_length_of(:password).is_at_least(8)}
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe "callbacks" do
    describe "after update" do
      let!(:user){ create(:user, email: "emailtest@testemail.com") }

      context "for send welcome to practice email" do
        it { expect(user).to callback(:welcome_to_practice_email).after(:update) }

        it "should send user an email to welcome to practice after user confirmed account" do
          expect{ user.confirm }.to change(Delayed::Job, :count).by(1)
        end
      end

      context "for notify primary guardian about sencond guardain joined leo" do
        let(:onboarding_group){ create(:onboarding_group) }
        let!(:secondary_guardian){ create(:user, onboarding_group: onboarding_group, family: user.family) }

        before do
          secondary_guardian.confirm
        end

        it { expect(secondary_guardian).to callback(:welcome_to_practice_email).after(:update) }

        it "should create a message" do
          expect( user.family.conversation.messages.last.body ).to eq("#{secondary_guardian.first_name} has joined Leo")
        end
      end
    end
  end

  describe ".customer_service_user" do
    let!(:customer_service_two){ create(:user, :customer_service) }
    let!(:guardian){ create(:user) }

    it "should return the first customer service staff" do
      expect(User.customer_service_user).to eq(customer_service)
    end
  end
end
