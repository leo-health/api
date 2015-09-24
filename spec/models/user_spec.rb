require 'rails_helper'

RSpec.describe User, type: :model do
  it{ is_expected.to belong_to(:family) }
  it{ is_expected.to belong_to(:role) }
  it{ is_expected.to belong_to(:practice) }

  it{ is_expected.to have_one(:provider_profile).with_foreign_key('provider_id') }

  it{ is_expected.to have_many(:user_conversations) }
  it{ is_expected.to have_many(:conversations).through(:user_conversations) }
  it{ is_expected.to have_many(:read_receipts).with_foreign_key('reader_id') }
  it{ is_expected.to have_many(:assigned_escalation_notes).class_name('EscalationNote').with_foreign_key('assignee_id') }
  it{ is_expected.to have_many(:read_messages).class_name('Message').with_foreign_key('read_receipts') }
  it{ is_expected.to have_many(:sessions) }
  it{ is_expected.to have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id') }
  it{ is_expected.to have_many(:escalated_messages).class_name('Message').with_foreign_key('escalated_by_id') }
  it{ is_expected.to have_many(:escalations).class_name('Message').with_foreign_key('escalated_to_id') }
  it{ is_expected.to have_many(:provider_appointments).class_name('Appointment').with_foreign_key('provider_id') }
  it{ is_expected.to have_many(:booked_appointments).class_name('Appointment').with_foreign_key('booked_by_id') }

  describe "validations" do
    subject { FactoryGirl.build(:user) }

    it { is_expected.to validate_length_of(:password).is_at_least(8)}
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).scoped_to(:deleted_at).case_insensitive }
  end
end
