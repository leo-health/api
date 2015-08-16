class Appointment < ActiveRecord::Base
  belongs_to :patient
  belongs_to :booked_by
  belongs_to :provider
  belongs_to :appointment_type

  validates :duration, :athena_id, :start_datetime, :status_id, :status,
            :appointment_type, :booked_by, :provider, :patient, presence: true

  def pre_checked_in?
    return future? || open? || cancelled?
  end

  def post_checked_in?
    return !pre_checked_in?
  end

  def booked?
    return future? || checked_in? || checked_out? || charge_entered?
  end

  def cancelled?
    return appointment_status == "x"
  end

  def future?
    return appointment_status == "f"
  end

  def open?
    return appointment_status == "o"
  end

  def checked_in?
    return appointment_status == "2"
  end

  def checked_out?
    return appointment_status == "3"
  end

  def charge_entered?
    return appointment_status == "4"
  end

	def self.MAX_DURATION
		40
  end

	def self.MIN_DURATION
		10
	end
end
