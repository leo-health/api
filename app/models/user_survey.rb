class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient

  validates_presence_of :user, :survey, :patient
end
