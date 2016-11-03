class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :question

  validates_presence_of :user_survey, :question
  validates_uniqueness_of :question_id, scope: :user_survey_id
  after_commit :mark_survey_complete_and_upload, on: :create

  private

  def mark_survey_complete_and_upload
    if question.order.to_i == Question.where(survey: user_survey.survey).count
      user_survey.delay.upload_survey_to_athena if user_survey.update_attributes(completed: true)
    end
  end
end
