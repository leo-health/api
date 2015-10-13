class Appointment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :patient
  belongs_to :booked_by, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment_type
  belongs_to :appointment_status
  belongs_to :practice

  validates :duration, :athena_id, :start_datetime, :appointment_status,
            :appointment_type, :booked_by, :provider, :patient, :practice, presence: true

  validate :same_family, on: :create
  validates_uniqueness_of :start_datetime, scope: :provider_id, conditions: -> { where(deleted_at: nil)}

  def same_family
    return unless (patient && booked_by)
    errors.add(:patient_id, "patient and guardian should have same family") unless patient.family_id == booked_by.family_id
  end

  #helpers for athena appointment statuses
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
    appointment_status.status == "x"
  end

  def future?
    appointment_status.status == "f"
  end

  def open?
    appointment_status.status == "o"
  end

  def checked_in?
    appointment_status.status == "2"
  end

  def checked_out?
    appointment_status.status == "3"
  end

  def charge_entered?
    appointment_status.status == "4"
  end
end
