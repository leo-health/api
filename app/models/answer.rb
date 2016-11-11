class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :question
  validates_presence_of :user_survey, :question
  validates_uniqueness_of :question_id, scope: :user_survey_id
  after_commit :mark_survey_complete_and_upload, on: :create

  def paint_mchat_answer_red?
    if question.survey.mchat?
      if MCHAT_POSITIVE_QUESTIONS.include?(question.id)
        return true if text.to_sym == :yes
      else
        return true if text.to_sym == :no
      end
    end
    false
  end


  private

  def mark_survey_complete_and_upload
    if question.order.to_i == Question.where(survey: user_survey.survey).count
      user_survey.delay.upload_survey_to_athena if user_survey.update_attributes(completed: true)
    end
  end
end
