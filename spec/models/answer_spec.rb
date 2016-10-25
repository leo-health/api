require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user_survey) }
    it{ is_expected.to belong_to(:question) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user_survey) }
    it { is_expected.to validate_presence_of(:question) }
  end
end
