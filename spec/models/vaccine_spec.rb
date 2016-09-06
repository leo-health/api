require 'rails_helper'

RSpec.describe Vaccine, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:patient) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:patient) }
  end
end
