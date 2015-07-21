class Role < ActiveRecord::Base
  has_many :user_roles
  has_many :users, :through => :user_roles
  has_many :patients

  validates :name, presence: true
  validates_uniqueness_of :name
end
