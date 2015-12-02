class OnboardingGroup < ActiveRecord::Base
  has_many :enrollments
  has_many :users

  validates :group_name, presence: true
end
