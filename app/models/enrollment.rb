class Enrollment < ActiveRecord::Base
  devise :database_authenticatable
  acts_as_paranoid
  acts_as_token_authenticatable

  has_many :patient_enrollments, foreign_key: "guardian_enrollment_id"

  before_validation :ensure_authentication_token, on: [:create, :update]
  validates :authentication_token, :email, presence: true
  validates :password, presence: true, if: :password_required?, on: :create
  validates_format_of :email, with: Devise.email_regexp, if: :email_changed?
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_uniqueness_of :authentication_token, conditions: -> { where(deleted_at: nil) }

  private

  def password_required?
    invited_user ? false : true
  end
end
