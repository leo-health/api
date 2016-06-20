class OnboardingGroup < ActiveRecord::Base
  has_many :enrollments
  has_many :users

  validates :group_name, presence: true

  class << self
    def primary_guardian
      find_or_create_by group_name: :primary_guardian
    end

    def invited_secondary_guardian
      find_or_create_by group_name: :invited_secondary_guardian
    end

    def generated_from_athena
      find_or_create_by group_name: :generated_from_athena
    end
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
