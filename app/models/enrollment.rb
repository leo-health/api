class Enrollment < ActiveRecord::Base
  devise :database_authenticatable, :validatable
  acts_as_paranoid
  acts_as_token_authenticatable

  has_many :patient_enrollments, foreign_key: "guardian_enrollment_id"

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :authentication_token, presence: true
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil)}

  def password_required?
    super || is_invite
  end
end
