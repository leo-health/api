class Enrollment < ActiveRecord::Base
  devise :database_authenticatable

  validates_uniqueness_of :email
end
