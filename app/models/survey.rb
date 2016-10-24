class Survey < ActiveRecord::Base
  has_many :questions
  has_many :user_surveys
  has_many :users, through: :user_surveys
  validates_presence_of :name, :private, :required, :reason
end
