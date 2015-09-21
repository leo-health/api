class Enrollment < ActiveRecord::Base
  devise :database_authenticatable
  acts_as_paranoid

  validates :password, length: {minimum: 8, allow_nil: true}
  validates :email, presence: true
end
