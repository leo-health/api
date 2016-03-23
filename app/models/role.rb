class Role < ActiveRecord::Base
  has_many :users
  has_many :patients

  scope :staff, -> { where(name: %i(financial clinical_support customer_service clinical operational)) }
  scope :clinical_staff, -> { where(name: %i(clinical_support customer_service clinical)) }
  scope :guardian, -> {where(name: %i(guardian)) }
  validates :name, presence: true
  validates_uniqueness_of :name
end
