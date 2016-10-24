class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :choices

  validates_presence_of :survey
end
