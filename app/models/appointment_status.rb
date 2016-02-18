class AppointmentStatus < ActiveRecord::Base
  STATUS_CANCELLED = 'x'
  STATUS_FUTURE = 'f'
  STATUS_OPEN = 'o'
  STATUS_CHECKED_IN = '2'
  STATUS_CHECKED_OUT = '3'
  STATUS_CHARGE_ENTERED = '4'

  STATUSES_BOOKED = [ STATUS_FUTURE, STATUS_CHECKED_IN, STATUS_CHECKED_OUT, STATUS_CHARGE_ENTERED ]
  STATUSES_PRECHECKEDIN = [ STATUS_FUTURE, STATUS_OPEN, STATUS_CANCELLED ]
  STATUSES_POSTCHECKEDIN = [ STATUS_CHECKED_IN, STATUS_CHECKED_OUT, STATUS_CHARGE_ENTERED ]

  has_many :appointments

  validates :description, :status, presence: true
  validates_uniqueness_of :description, :status

  def self.cancelled
    find_by!(status: STATUS_CANCELLED)
  end

  def self.future
    find_by!(status: STATUS_FUTURE)
  end

  def self.booked
    where(status: STATUSES_BOOKED).all
  end
end
