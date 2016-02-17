class Enrollment < ActiveRecord::Base
  devise :database_authenticatable
  acts_as_paranoid
  acts_as_token_authenticatable

  has_many :patient_enrollments, foreign_key: "guardian_enrollment_id"
  belongs_to :insurance_plan
  belongs_to :role
  belongs_to :onboarding_group
  belongs_to :family

  before_validation :ensure_authentication_token, on: [:create, :update]

  validates :email, :role, presence: true
  validates :family, :onboarding_group, presence: true, if: :invited?
  validates :password, presence: true, on: :create, unless: :invited?
  validates_format_of :email, with: Devise.email_regexp
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  private

  def invited?
    !!onboarding_group.try(:invited_secondary_guardian?)
  end
end
