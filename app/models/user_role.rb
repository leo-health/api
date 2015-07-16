class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  validates :user_id, :role_id, presence: true
  validates_uniqueness_of :user_id, :scope => :role_id
end
