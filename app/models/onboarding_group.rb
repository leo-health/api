class OnboardingGroup < ActiveRecord::Base
  has_many :enrollments
  has_many :users

  validates :group_name, presence: true

  def invited_secondary_guardian?
    group_name.to_sym == :invited_secondary_guardian
  end
end
