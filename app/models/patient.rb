class Patient < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :family
  belongs_to :role
  has_many :appointments
  has_one :health_record

  validates :first_name, :last_name, :birth_date, :sex, :family, presence: true
end
