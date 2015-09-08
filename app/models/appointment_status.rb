class AppointmentStatus < ActiveRecord::Base
  belongs_to :appointment

  validates :description, :status, presence: true
  validates_uniqueness_of :description, :status
end
