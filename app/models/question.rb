class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :choices

  validate_presence_of :survey
end
