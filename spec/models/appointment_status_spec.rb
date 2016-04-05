require 'rails_helper'

RSpec.describe AppointmentStatus, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:appointments) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }

    it { is_expected.to validate_uniqueness_of(:description) }
    it { is_expected.to validate_uniqueness_of(:status) }
  end

  describe "scope" do
    context "booked" do
      let!(:future_appointment_status){ create(:appointment_status, :future) }
      let!(:cancelled_appointment_status){ create(:appointment_status, :cancelled) }

      it "should return booked appointment status" do
        expect(AppointmentStatus.booked).to eq([future_appointment_status])
      end
    end
  end

  describe ".cancelled" do
    let!(:cancelled_appointment_status){ create(:appointment_status, :cancelled) }

    it "should return cancelled appointment status" do
      expect(AppointmentStatus.cancelled).to eq(cancelled_appointment_status)
    end
  end

  describe ".future" do
    let!(:future_appointment_status){ create(:appointment_status, :future) }

    it "should return cancelled appointment status" do
      expect(AppointmentStatus.future).to eq(future_appointment_status)
    end
  end
end
