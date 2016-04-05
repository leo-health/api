class Appointment < ActiveRecord::Base
  MIN_INTERVAL_TO_SCHEDULE = 15.minutes

  acts_as_paranoid
  belongs_to :patient
  belongs_to :booked_by, class_name: "User"
  belongs_to :provider, class_name: "User"
  belongs_to :appointment_type
  belongs_to :appointment_status
  belongs_to :practice
  validates :duration, :athena_id, :start_datetime, :appointment_status, :appointment_type, :booked_by, :provider, :practice, presence: true
  validates_presence_of :patient, unless: :booked_by_provider?
  validate :same_family?, on: :create
  validates_uniqueness_of :start_datetime, scope: :provider_id, if: :booked?,
    conditions: -> { where(deleted_at: nil, athena_id: 0, appointment_status: AppointmentStatus.booked) }

  scope :booked, -> { where(appointment_status: AppointmentStatus.booked)}

  def post_to_athena
    SyncServiceHelper::Syncer.new.sync_leo_appointment self
  end

  def same_family?
    return unless booked_by.try(:guardian?)
    errors.add(:patient_id, "patient and guardian should have same family") unless patient.try(:family_id) == booked_by.try(:family_id)
  end

  def booked_by_provider?
    booked_by.try(:provider?)
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
    appointment_status.try(:status) == AppointmentStatus::STATUS_CANCELLED
  end

  def future?
    appointment_status.try(:status) == AppointmentStatus::STATUS_FUTURE
  end

  def open?
    appointment_status.try(:status) == AppointmentStatus::STATUS_OPEN
  end

  def checked_in?
    appointment_status.try(:status) == AppointmentStatus::STATUS_CHECKED_IN
  end

  def checked_out?
    appointment_status.try(:status) == AppointmentStatus::STATUS_CHECKED_OUT
  end

  def charge_entered?
    appointment_status.try(:status) == AppointmentStatus::STATUS_CHARGE_ENTERED
  end
end
