require 'rails_helper'

RSpec.describe UserSurvey, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user) }
    it{ is_expected.to belong_to(:survey) }
    it{ is_expected.to belong_to(:patient) }
    it{ is_expected.to have_many(:answers) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:survey) }
    it { is_expected.to validate_presence_of(:patient) }
  end
end
