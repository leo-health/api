require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'relations' do
    it{ is_expected.to belong_to(:patient) }
    it{ is_expected.to belong_to(:practice) }
    it{ is_expected.to belong_to(:booked_by).class_name('User') }
    it{ is_expected.to belong_to(:provider).class_name('User') }
    it{ is_expected.to belong_to(:appointment_type) }
    it{ is_expected.to belong_to(:appointment_status) }
  end

  describe 'validations' do
    subject { FactoryGirl.create(:appointment, :future) }

    it { is_expected.to validate_presence_of(:duration) }
    it { is_expected.to validate_presence_of(:athena_id) }
    it { is_expected.to validate_presence_of(:practice) }
    it { is_expected.to validate_presence_of(:start_datetime) }
    it { is_expected.to validate_presence_of(:appointment_status) }
    it { is_expected.to validate_presence_of(:appointment_type) }
    it { is_expected.to validate_presence_of(:booked_by) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:patient) }
    it { is_expected.to validate_uniqueness_of(:start_datetime).scoped_to(:provider_id) }
  end

  describe 'same_family?' do
    let(:first_family){create(:family)}
    let(:second_family){create(:family)}
    let(:patient){create(:patient, family: first_family)}
    let(:guardian){create(:user, :guardian, family: second_family)}

    it 'should raise error' do
      appointment = Appointment.new(patient: patient, booked_by: guardian)
      appointment.valid?
      expect(appointment.errors[:patient_id]).to eq(["patient and guardian should have same family"])
    end
  end
end
