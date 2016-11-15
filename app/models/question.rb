class Question < ActiveRecord::Base
  belongs_to :survey
  has_many :choices
  has_many :answers

  validates_presence_of :survey, :body, :order, :question_type
  validates_inclusion_of :question_type, in: %w(single\ select multi\ select single\ line multi\ line rating/numerical)
end
