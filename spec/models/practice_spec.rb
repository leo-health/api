require 'rails_helper'

RSpec.describe Practice, type: :model do
  describe "relations" do
    it{ is_expected.to have_many(:staff).conditions(role_id: [2, 3, 5]) }
    it{ is_expected.to have_many(:guardians).conditions(role_id: 4) }
    it{ is_expected.to have_many(:appointments) }
    it{ is_expected.to have_many(:practice_schedules) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
