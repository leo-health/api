require 'rails_helper'

RSpec.describe Practice, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:staff).class_name('User') }
    it{ is_expected.to have_many(:guardians).class_name('User') }
    it{ is_expected.to have_many(:appointments) }
    it{ is_expected.to have_many(:practice_schedules) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "in_office_hour?" do
    let(:practice){ create(:practice) }
    let!(:practice_schedule){ create(:practice_schedule, practice: practice) }

    context "practice is open now" do
      before do
        Timecop.freeze(Time.zone.local(2015, 12, 10, 9, 1, 0))
      end

      after do
        Timecop.return
      end

      it "should return true" do
        expect(practice.in_office_hour?).to eq(true)
      end
    end

    context "practice is closed now" do
      before do
        Timecop.freeze(Time.zone.local(2015, 12, 10, 17, 1, 0))
      end

      after do
        Timecop.return
      end

      it "should return false" do
        expect(practice.in_office_hour?).to eq(false)
      end
    end
  end
end
