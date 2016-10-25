class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :patient
  belongs_to :choice
  belongs_to :question

  validates_presence_of :user, :question
  after_commit :check_survey_completeness

  private

  def check_survey_completeness
    questions = Question.where(survey: question.survey)
    answers = Answer.where(question: questions)
    if questions.count == answers.count
      UserSurvey.where(survey: question.survey, )
    end
  end
end
