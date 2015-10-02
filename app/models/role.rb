class Role < ActiveRecord::Base
  has_many :users
  has_many :patients

  validates :name, presence: true
  validates_uniqueness_of :name
end
