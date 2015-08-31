class Appointment < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :patient
  belongs_to :booked_by, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment_type

  validates :duration, :athena_id, :start_datetime, :status_id, :status,
            :appointment_type, :booked_by, :provider, :patient, presence: true

  validate :same_family, on: :create

  validates_uniqueness_of :start_datetime, scope: :provider_id

  def same_family
    return unless (patient && booked_by)
    errors.add(:patient_id, "patient and guardian should have same family") unless patient.family_id == booked_by.family_id
  end

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
    status == "x"
  end

  def future?
    status == "f"
  end

  def open?
    status == "o"
  end

  def checked_in?
    status == "2"
  end

  def checked_out?
    status == "3"
  end

  def charge_entered?
    status == "4"
  end
end
