class OnboardingGroup < ActiveRecord::Base
  has_many :enrollments
  has_many :users

  validates :group_name, presence: true

  def self.primary_guardian
    find_by group_name: :primary_guardian
  end

  def self.invited_secondary_guardian
    find_by group_name: :invited_secondary_guardian
  end

  def self.generated_from_athena
    find_by group_name: :generated_from_athena
  end

  def primary_guardian?
    group_name.to_sym == :primary_guardian
  end

  def invited_secondary_guardian?
    group_name.to_sym == :invited_secondary_guardian
  end

  def generated_from_athena?
    group_name.to_sym == :generated_from_athena
  end
end
