class Role < ActiveRecord::Base
  has_many :users
  scope :staff_roles, -> { where(name: %i(financial clinical_support customer_service clinical operational)) }
  scope :clinical_staff_roles, -> { where(name: %i(clinical_support customer_service clinical)) }
  scope :guardian_roles, -> { where(name: :guardian)}
  scope :provider_roles, -> { where(name: :clinical)}
  validates :name, presence: true
  validates_uniqueness_of :name

  def self.clinical
    Role.find_by(name: :clinical)
  end

  def self.guardian
    Role.find_by(name: :guardian)
  end
end
