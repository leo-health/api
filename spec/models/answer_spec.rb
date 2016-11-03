require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user_survey) }
    it{ is_expected.to belong_to(:question) }
  end

  describe "validations" do
    let!(:answer){ create(:answer) }

    it { is_expected.to validate_presence_of(:user_survey) }
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:user_survey_id) }
  end

  describe "after commit" do
    let(:user_survey){ create(:user_survey) }
    let(:question){ create(:question, order: 1, survey: user_survey.survey) }

    def answer_last_question
      @answer = Answer.create(user_survey: user_survey, question: question)
    end

    it "should mark user survey as compelte if the last question is answered" do
      expect{ answer_last_question }.to change(user_survey, :completed).from(false).to(true)
    end
  end
end
