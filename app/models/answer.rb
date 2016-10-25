class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :question

  validates_presence_of :user_survey, :question
end
