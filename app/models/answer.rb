class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :choice

  validates_presence_of :user, :choice
end
