class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :choice
  belongs_to :question

  validates_presence_of :user, :question
end
