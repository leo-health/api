class Role < ActiveRecord::Base
  has_many :users
  has_many :patients

  scope :staff_roles, -> { where(name: %i(financial clinical_support customer_service clinical operational)) }
  scope :clinical_staff_roles, -> { where(name: %i(clinical_support customer_service clinical)) }
  scope :guardian_roles, -> { where(name: :guardian)}
  validates :name, presence: true
  validates_uniqueness_of :name

  def self.guardian
    Role.find_by(name: :guardian)
  end
end
