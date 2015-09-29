class Enrollment < ActiveRecord::Base
  devise :database_authenticatable
  acts_as_paranoid
  acts_as_token_authenticatable

  has_many :patient_enrollments, foreign_key: "guardian_enrollment_id"

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :password, length: {minimum: 8, allow_nil: true}
  validates :email, :authentication_token, presence: true
  validates :authentication_token, uniqueness: {scope: :deleted_at}
end
