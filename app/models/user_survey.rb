class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient
  has_many :answers

  validates_presence_of :user, :survey
end
