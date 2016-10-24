require 'rails_helper'

RSpec.describe Question, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:survey) }
    it{ is_expected.to have_many(:choices) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:order) }
    it { is_expected.to validate_presence_of(:survey) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:question_type) }
  end
end