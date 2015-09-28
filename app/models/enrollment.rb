class Enrollment < ActiveRecord::Base
  devise :database_authenticatable
  acts_as_paranoid

  has_many :patient_enrollments, foreign_key: "guardian_enrollment_id"

  validates :password, length: {minimum: 8, allow_nil: true}
  validates :email, presence: true
end
