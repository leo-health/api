require 'rails_helper'
require 'mandrill_mailer/offline'

describe User do
  describe "relations" do
    it{ is_expected.to belong_to(:family) }
    it{ is_expected.to belong_to(:role) }
    it{ is_expected.to belong_to(:practice) }
    it{ is_expected.to belong_to(:onboarding_group) }
    it{ is_expected.to belong_to(:insurance_plan) }

    it{ is_expected.to have_one(:avatar) }
    it{ is_expected.to have_one(:staff_profile).with_foreign_key('staff_id') }
    it{ is_expected.to have_one(:provider) }

    it{ is_expected.to have_many(:forms) }
    it{ is_expected.to have_many(:user_conversations) }
    it{ is_expected.to have_many(:conversations).through(:user_conversations) }
    it{ is_expected.to have_many(:read_receipts).with_foreign_key('reader_id') }
    it{ is_expected.to have_many(:escalation_notes).class_name('EscalationNote').with_foreign_key('escalated_to_id') }
    it{ is_expected.to have_many(:closure_notes).class_name('ClosureNote').with_foreign_key('closed_by_id') }
    it{ is_expected.to have_many(:read_messages).class_name('Message').with_foreign_key('read_receipts') }
    it{ is_expected.to have_many(:sessions) }
    it{ is_expected.to have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id') }
    it{ is_expected.to have_many(:booked_appointments).class_name('Appointment').with_foreign_key('booked_by_id') }
    it{ is_expected.to have_many(:user_generated_health_records) }

    describe "has many booked appointments" do
      let(:guardian){ create(:user, :guardian) }
      let(:provider){ create(:provider) }
      let!(:cancelled_appointment){ create(:appointment, :cancelled, booked_by: guardian, provider: provider, start_datetime: 1.minutes.ago) }
      let!(:checked_in_appointment){ create(:appointment, :checked_in, booked_by: guardian, provider: provider, start_datetime: 2.minutes.ago) }
      let!(:charge_entered_appointment){ create(:appointment, :charge_entered, booked_by: guardian, provider: provider, start_datetime: 3.minutes.ago) }
      let!(:open_appointmet){ create(:appointment, :open, booked_by: guardian, provider: provider) }

      it "should return booked appointments" do
        expect(guardian.booked_appointments.sort).to eq([checked_in_appointment, charge_entered_appointment].sort)
      end
    end
  end

  describe "scopes" do
    context "guaridans" do
      let!(:guardian){ create(:user) }

      it "should return all the guaridans" do
        expect(User.guardians).to match_array([guardian])
      end
    end

    context "staff" do
      let!(:customer_service){ create(:user, :customer_service) }
      let!(:clinical){ create(:user, :clinical) }

      it "should return all the staff" do
        expect(User.staff).to match_array([clinical, customer_service])
      end
    end

    context "provider" do
      let!(:customer_service){ create(:user, :customer_service) }
      let!(:clinical){ create(:user, :clinical) }

      it "should return all the providers" do
        expect(User.provider).to match_array([clinical])
      end
    end

    context "completed_or_athena" do
      let(:generated_from_athena){ create(:onboarding_group, :generated_from_athena) }
      let!(:completed){ create(:user, complete_status: :complete) }
      let!(:athena){ create(:user, onboarding_group: generated_from_athena) }

      it "should return all the user with complete status and generated_from_athena onboarding group" do
        expect(User.completed_or_athena).to match_array([athena, completed])
      end
    end
  end

  describe "before validations" do
    let(:customer_service){ create(:user, :customer_service) }
    let!(:guardian){ create(:user, :guardian, phone: "+1(123)234-9848") }
    let(:customer_service_practice){ customer_service.practice }

    it "should format phone numbers to number only, exclude all symbols" do
      expect( guardian.phone ).to eq("1232349848")
    end

    context "when user is a guardian" do
      it "should add default practice" do
        expect(guardian.practice).not_to eq(nil)
      end

      it "should add family if not has one" do
        expect(guardian.family).not_to eq(nil)
      end

      it "should add vendor_id" do
        expect(guardian.vendor_id).not_to eq(nil)
      end
    end

    context "when user is an invited or exempted guardian" do
      let(:invited_onboarding_group){ create :onboarding_group, :invited_secondary_guardian}

      before do
        guardian.update_attributes(onboarding_group: invited_onboarding_group)
      end

      it "should add invitation token" do
        expect(guardian.invitation_token).not_to eq(nil)
      end
    end

    context "when user is not a guardian" do
      it "should not add default practice" do
        expect(customer_service.practice).to eq(customer_service_practice)
      end

      it "should not add family" do
        expect(customer_service.family).to eq(nil)
      end

      it "should not add vendor_id" do
        expect(customer_service.vendor_id).to eq(nil)
      end
    end
  end

  describe "validations" do
    subject { build(:user, complete_status: :complete) }

    before do
      subject.validate
    end

    it { is_expected.to validate_length_of(:password).is_at_least(8)}
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_uniqueness_of(:invitation_token).allow_nil }
    it { is_expected.to validate_uniqueness_of(:vendor_id).allow_nil }

    context "if provider" do
      before { allow(subject).to receive(:clinical?).and_return(true)}
      it { should validate_presence_of(:provider) }
    end

    context "if not provider" do
      before { allow(subject).to receive(:clinical?).and_return(false)}
      it { should_not validate_presence_of(:provider) }
    end

    context "if complete or in generated_from_athena onboarding group" do
      subject { create(:user, complete_status: :complete, email: "dup@dup.com") }

      it "should raise error if email is not unique for two completed user" do
        expect { subject.dup.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "callbacks" do
    let!(:user){ create(:user, email: "emailtest@testemail.com", first_name: "first") }
    let(:onboarding_group){ create(:onboarding_group) }
    let!(:secondary_guardian){ create(:user, onboarding_group: onboarding_group, first_name: "second", family: user.family) }

    describe "after commit on create" do
      context "for secondary guardian" do
        it "should send a welcome to practice email" do
          expect{ secondary_guardian.confirm_secondary_guardian }.to change{ Delayed::Job.where(queue: 'notification_email').count }.by(1)
        end
      end
    end
  end

  describe ".customer_service_user" do
    let!(:customer_service){ create(:user, :customer_service) }
    let!(:customer_service_two){ create(:user, :customer_service) }
    let!(:guardian){ create(:user) }

    it "should return the first customer service staff" do
      expect(User.customer_service_user).to eq(customer_service)
    end
  end

  describe "#primary_guardian?" do
    let(:customer_service){ create(:user, :customer_service) }
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
      expect(user.collect_device_tokens.sort).to eq(uniq_tokens.sort)
    end
  end

  describe "#invited_user?" do
    let(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
    let(:invited_user){ create(:user, onboarding_group: onboarding_group) }

    it "should return true if a user is being invited" do
      expect(invited_user.invited_user?).to eq(true)
    end
  end

  describe "#exempted_user?" do
    let(:onboarding_group){ create(:onboarding_group, :generated_from_athena) }
    let(:exempted_user){ create(:user, onboarding_group: onboarding_group) }
    before do
      exempted_user.family.exempt_membership!
    end

    it "should return true if a user is being invited" do
      expect(exempted_user.exempted_user?).to eq(true)
    end
  end

  describe "#set_complete" do
    it "should send a Leo - Welcome To Practice email, email confirmation email, and create a conversation" do
      user = create(:user, :guardian)
      expect(Delayed::Job.where(queue: "notification_email").count).to eq(1)
      expect(Delayed::Job.where(queue: "registration_email").count).to eq(1)
      expect(user.family.conversation).not_to be(nil)
    end
  end

  describe "#invitation_token_expired?" do
    let(:user){ create(:user, invitation_sent_at: Time.now - (User::EXPIRATION_PERIOD + 1.day)) }

    it "should return true if the invitation token is expired" do
      expect(user.invitation_token_expired?).to eq(true)
    end
  end

  describe "#invitation_url" do
    context "secondary" do
      let(:onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
      let(:invited_user){ create(:user, onboarding_group: onboarding_group) }

      it "should return a secondary invite link" do
        expected_group = "secondary"
        expected_url = "#{ENV['PROVIDER_APP_HOST']}/registration/invited?onboarding_group=#{expected_group}&token=#{invited_user.invitation_token}"
        expect(invited_user.invitation_url).to eq(expected_url)
      end
    end

    context "else exempted" do
      let(:user){ create(:user, :guardian) }

      let(:onboarding_group){ create(:onboarding_group, :generated_from_athena) }
      let(:exempted_user){ create(:user, onboarding_group: onboarding_group) }

      before do
        exempted_user.family.exempt_membership!
      end

      def expected_url(user)
        expected_group = "primary"
        "#{ENV['PROVIDER_APP_HOST']}/registration/invited?onboarding_group=#{expected_group}&token=#{user.invitation_token}"
      end

      it "should return a primary invite link for an exempted_user" do
        expect(exempted_user.invitation_url).to eq(expected_url(exempted_user))
      end

      it "should raise error if user isn't generated_from_athena or secondary" do
        expect{ user.invitation_url }.to raise_error(RuntimeError, "User #{user.id} is not invited or exempt. They should sign up through normal onboarding")
      end
    end
  end
end
