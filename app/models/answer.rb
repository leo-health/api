class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :question

  validates_presence_of :user_survey, :question
  after_commit :mark_survey_complete, on: :create

  private

  def mark_survey_complete
    if question.order == user_survey.survey.questions.count - 1
      user_survey.update_attributes(completed: true)
    end
  end
end
