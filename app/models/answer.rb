class Answer < ActiveRecord::Base
  belongs_to :user_survey
  belongs_to :patient
  belongs_to :choice
  belongs_to :question

  validates_presence_of :user, :question
end
