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
end
