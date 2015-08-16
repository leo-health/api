class AppointmentType < ActiveRecord::Base
  has_many :appointments

  validates :name, :duration, :athena_id, presence: true
end
