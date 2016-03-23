require 'rails_helper'

describe User do
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:bot){ create(:user, :bot)}

  describe "relations" do
    let(:guardian){ create(:user, :guardian) }
    let(:provider){ create(:user, :clinical) }
    let!(:cancelled_appointment){ create(:appointment, :cancelled, booked_by: guardian, provider: provider, start_datetime: 1.minutes.ago) }
    let!(:checked_in_appointment){ create(:appointment, :checked_in, booked_by: guardian, provider: provider, start_datetime: 2.minutes.ago) }
    let!(:charge_entered_appointment){ create(:appointment, :charge_entered, booked_by: guardian, provider: provider, start_datetime: 3.minutes.ago) }
    let!(:open_appointmet){ create(:appointment, :open, booked_by: guardian, provider: provider) }

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
    it{ is_expected.to have_many(:provider_appointments).class_name('Appointment').with_foreign_key('provider_id') }
    it{ is_expected.to have_many(:booked_appointments).class_name('Appointment').with_foreign_key('booked_by_id') }
    it{ is_expected.to have_many(:user_generated_health_records) }

    describe "has many provider appointments" do
      it "should return provider appointments" do
        expect(provider.provider_appointments).to eq([checked_in_appointment, charge_entered_appointment])
      end
    end

    describe "has many booked appointments" do
      it "should return booked appointments" do
        expect(guardian.booked_appointments).to eq([checked_in_appointment, charge_entered_appointment])
      end
    end
  end

  describe "before validations" do
    let!(:guardian){ create(:user, :guardian, phone: "+1(123)234-9848") }
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

    it "should format phone numbers to number only, exclude all symbols" do
      expect( guardian.phone ).to eq("1232349848")
    end
  end

  describe "validations" do
    subject { build(:user) }

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
    end

    describe "after commit on create" do
      it { expect(user).to callback(:set_user_type_on_secondary_user).after(:commit) }

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
