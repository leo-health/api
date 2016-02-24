require 'rails_helper'

describe User do
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:bot){ create(:user, :bot)}

  describe "relations" do
    let(:booked_appointment_status){ create(:appointment_status, :checked_in) }

    it{ is_expected.to belong_to(:family) }
    it{ is_expected.to belong_to(:role) }
    it{ is_expected.to belong_to(:practice) }
    it{ is_expected.to belong_to(:onboarding_group) }
    it{ is_expected.to belong_to(:insurance_plan) }

    it{ is_expected.to have_one(:avatar) }
    it{ is_expected.to have_one(:staff_profile).with_foreign_key('staff_id') }
    it{ is_expected.to have_one(:provider_sync_profile).with_foreign_key('provider_id') }

    it{ is_expected.to have_many(:user_conversations) }
    it{ is_expected.to have_many(:forms) }
    it{ is_expected.to have_many(:conversations).through(:user_conversations) }
    it{ is_expected.to have_many(:read_receipts).with_foreign_key('reader_id') }
    it{ is_expected.to have_many(:escalation_notes).class_name('EscalationNote').with_foreign_key('escalated_to_id') }
    it{ is_expected.to have_many(:closure_notes).class_name('ClosureNote').with_foreign_key('closed_by_id') }
    it{ is_expected.to have_many(:read_messages).class_name('Message').with_foreign_key('read_receipts') }
    it{ is_expected.to have_many(:sessions) }
    it{ is_expected.to have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id') }
    it{ is_expected.to have_many(:provider_appointments).class_name('Appointment').with_foreign_key('provider_id')}
      # conditions(appointment_status: booked_appointment_status) }
    it{ is_expected.to have_many(:booked_appointments).class_name('Appointment').with_foreign_key('booked_by_id').
      conditions(appointment_status: booked_appointment_status) }
    it{ is_expected.to have_many(:user_generated_health_records) }
  end

  describe "before validations" do
    let!(:guardian){ create(:user, :guardian) }
    let(:customer_service_practice){ customer_service.practice }

    it "should add default practice to guardian" do
      expect(guardian.practice).not_to eq(nil)
    end

    it "should add family to guardian if not has one" do
      expect(guardian.family).not_to eq(nil)
    end

    it "should not add default practice or default family to staff" do
      expect(customer_service.family).to eq(nil)
      expect(customer_service.practice).to eq(customer_service_practice)
    end
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
    let(:user){ create(:user, email: "emailtest@testemail.com", first_name: "first") }
    let(:onboarding_group){ create(:onboarding_group) }
    let!(:secondary_guardian){ create(:user, onboarding_group: onboarding_group, first_name: "second", family: user.family) }

    describe "after update" do
      context "for send welcome to practice email" do
        it { expect(user).to callback(:welcome_onboarding_notifications).after(:update) }

        it "should send user an email to welcome to practice after user confirmed account" do
          expect{ user.confirm }.to change(Delayed::Job, :count).by(1)
        end
      end

      context "for notify primary guardian about sencond guardian joined leo" do
        before do
          secondary_guardian.confirm
        end

        it { expect(secondary_guardian).to callback(:welcome_onboarding_notifications).after(:update) }

        it "should create a message" do
          expect( user.family.conversation.messages.last.body ).to eq("#{secondary_guardian.first_name} has joined Leo")
        end
      end
    end

    describe "after commit on create" do
      it { expect(user).to callback(:set_user_type_on_secondary_user).after(:commit) }

      # it "should set up a family for primary guardian" do
      #   byebug
      #   expect( user.family ).to exit
      # end

      context "for secondary guardian" do
        it "should set the user type of secondary guardian to be intentical to the primary guadian" do
          expect( secondary_guardian.type ).to eq(user.type)
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

  describe "#primary_guardian?" do
    let(:primary_guardian){ create(:user) }
    let(:secondary_guardian){ create(:user, family: primary_guardian.family) }

    it "should return true for primary guardian" do
      expect( primary_guardian.primary_guardian? ).to eq(true)
    end

    it "should return false for secondary guardian" do
      expect( secondary_guardian.primary_guardian? ).to eq(false)
    end

    it "should return false for staff" do
      expect( customer_service.primary_guardian? ).to eq(false)
    end
  end

  describe "#collect_device_tokens" do
    let(:device_tokens){ ['token_one', 'token_two', 'token_two'] }
    let(:uniq_tokens){ ['token_two', 'token_one'] }
    let(:user){ create(:user) }

    before do
      device_tokens.each do |device_token|
        user.sessions.create(device_token: device_token)
      end
    end

    it "should collect all the unique device tokens" do
      expect(user.collect_device_tokens).to eq(uniq_tokens)
    end
  end
end
