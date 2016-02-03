require 'rails_helper'

RSpec.describe ProviderSchedule, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:athena_provider_id) }
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
