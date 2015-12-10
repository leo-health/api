require 'rails_helper'

RSpec.describe PracticeSchedule, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:practice) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:practice) }
    it { is_expected.to validate_presence_of(:schedule_type) }
    it { is_expected.to validate_presence_of(:monday_start_time) }
    it { is_expected.to validate_presence_of(:monday_end_time) }
    it { is_expected.to validate_presence_of(:tuesday_start_time) }
    it { is_expected.to validate_presence_of(:tuesday_end_time) }
    it { is_expected.to validate_presence_of(:wednesday_start_time) }
    it { is_expected.to validate_presence_of(:wednesday_end_time) }
    it { is_expected.to validate_presence_of(:thursday_start_time) }
    it { is_expected.to validate_presence_of(:thursday_end_time) }
    it { is_expected.to validate_presence_of(:friday_start_time) }
    it { is_expected.to validate_presence_of(:friday_end_time) }
    it { is_expected.to validate_presence_of(:saturday_start_time) }
    it { is_expected.to validate_presence_of(:saturday_end_time) }
    it { is_expected.to validate_presence_of(:sunday_start_time) }
    it { is_expected.to validate_presence_of(:sunday_end_time) }
  end
end
