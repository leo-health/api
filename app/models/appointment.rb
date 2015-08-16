class Appointment < ActiveRecord::Base
  belongs_to :patient
  belongs_to :booked_by, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment_type

  validates :duration, :athena_id, :start_datetime, :status_id, :status,
            :appointment_type, :booked_by, :provider, :patient, presence: true

  validates_uniqueness_of :start_datetime, scope: :provider_id

  def pre_checked_in?
    future? || open? || cancelled?
  end

  def post_checked_in?
    !pre_checked_in?
  end

  def booked?
    future? || checked_in? || checked_out? || charge_entered?
  end

  def cancelled?
    appointment_status == "x"
  end

  def future?
    appointment_status == "f"
  end

  def open?
    appointment_status == "o"
  end

  def checked_in?
    appointment_status == "2"
  end

  def checked_out?
    appointment_status == "3"
  end

  def charge_entered?
    appointment_status == "4"
  end
end
