class Patient < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :family
  belongs_to :role
  has_many :appointments
  has_many :medications
  has_many :photos
  has_many :vaccines
  has_many :vitals
  has_many :insurances

  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
end
