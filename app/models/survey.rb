class Survey < ActiveRecord::Base
  has_many :questions
  validates_presence_of :name, :prompt, :description, :instruction, :private, :required, :reason
  has_many :user_surveys
  has_many :users, through: :user_surveys


  def completed_for?(patient)
    if user_survey = UserSurvey.find_by(patient: patient)
      return user_survey.completed?
    end
    false
  end
end
