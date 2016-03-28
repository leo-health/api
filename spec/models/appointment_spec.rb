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
  end

  describe 'validation' do
    let(:appt) { FactoryGirl.create(:appointment, :future) }

    it 'should raise error if start_datetime is duplicated' do
      expect { appt.dup.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Start datetime has already been taken')
    end
  end

  describe 'same_family?' do
    let(:first_family){create(:family)}
    let(:patient){create(:patient, family: first_family)}

    context "booked by a guaridan" do
      let(:guardian){create(:user, :guardian, family: second_family)}
      let(:second_family){create(:family)}

      it 'should raise error' do
        appointment = Appointment.new(patient: patient, booked_by: guardian)
        appointment.valid?
        expect(appointment.errors[:patient_id]).to eq(["patient and guardian should have same family"])
      end
    end

    context "booked by a provider" do
      let(:provider){ create(:user, :clinical) }

      it 'should allow booking by provider' do
        appointment = Appointment.new(patient: patient, booked_by: provider)
        appointment.valid?
        expect(appointment.errors[:patient_id]).to eq([])
      end
    end
  end
end
