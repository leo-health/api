class AppointmentStatus < ActiveRecord::Base
  has_many :appointments

  validates :description, :status, presence: true
  validates_uniqueness_of :description, :status
end
