class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  validates :user, :role, presence: true
  validates_uniqueness_of :user_id, :scope => :role_id
end
