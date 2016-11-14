require 'rails_helper'

describe Survey do
  describe "relations" do
    it{ is_expected.to have_many(:questions) }
    it{ is_expected.to have_many(:user_surveys) }
    it{ is_expected.to have_many(:users).through(:user_surveys) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:private) }
    it { is_expected.to validate_presence_of(:required) }
    it { is_expected.to validate_presence_of(:display_name) }
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_presence_of(:survey_type) }
    it { is_expected.to validate_inclusion_of(:survey_type).in_array(%w(clinical feedback tracking)) }
  end

  describe '.mchat?' do
    let(:survey){ create(:survey, name: :MCHAT24) }

    it "should return true if the survey is one of mchat surveys" do
      expect(survey.mchat?).to eq(true)
    end
  end
end
