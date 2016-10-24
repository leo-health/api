class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient

  validates_presence_of :user, :survey, :patient

  def finished_surveys(patient)
    UserSurvey.where(patient: patient)
  end

  def inprogress_surveys(patient)
    UserSurvey
  end

  def unstarted_surveys(patient)

  end
end



#user >- user_survey-< survey

