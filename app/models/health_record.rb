class HealthRecord < ActiveRecord::Base
  belongs_to :patient
  has_many :allergies
  has_many :medications
  has_many :photos
  has_many :vaccines
  has_many :vitals
  has_many :insurances

  validates :athena_id, presence: true
end
