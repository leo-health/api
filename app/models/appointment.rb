class Appointment < ActiveRecord::Base
  include StartDateTimeBetween

  MIN_INTERVAL_TO_SCHEDULE = 15.minutes

  acts_as_paranoid
  belongs_to :patient
  belongs_to :booked_by, polymorphic: true
  belongs_to :booked_by_user,  # Alternative way to query the 'booked_by' polymorphic association for Users only - used to construct compound 'where-s'
             -> { where(appointments: { booked_by_type: 'User' }) },
             class_name: 'User',
             foreign_key: :booked_by_id
  belongs_to :provider
  belongs_to :appointment_type
  belongs_to :appointment_status
  belongs_to :practice
  validates :duration, :athena_id, :start_datetime, :appointment_status, :appointment_type, :practice, presence: true
  validates_presence_of :patient, unless: :booked_by_provider?
  validate :same_family?, on: :create
  validates_uniqueness_of :start_datetime, scope: :provider_id, if: :booked?,
    conditions: -> { where(deleted_at: nil, athena_id: 0, appointment_status: AppointmentStatus.booked) }

  scope :booked, -> { where(appointment_status: AppointmentStatus.booked)}

  after_commit :mark_slots_as_busy, :create_surveys, on: :create, if: ->{ booked? }

  def mark_slots_as_busy
    # TODO: Remove me when bug is fixed
    Rails.logger.warn("booking appointment not yet saved to db patient_id:#{patient_id}, start_datetime:#{start_datetime}") unless id

    Slot.free.where(provider: provider)
    .start_date_time_between(start_datetime, end_datetime)
    .update_all(
      free_busy_type: :busy,
      appointment_id: id
    )
  end

  def end_datetime
    start_datetime + duration.minutes
  end

  def same_family?
    return unless booked_by.try(:guardian?)
    errors.add(:patient_id, "patient and guardian should have same family") unless patient.try(:family_id) == booked_by.try(:family_id)
  end

  def booked_by_provider?
    booked_by.try(:clinical?)
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

  def milestone_from_birth?(time, buffer)
    (start_datetime - patient.birth_date.to_datetime - time.months).abs < buffer.months
  end

  private

  def create_surveys
    if name = mchat_name
      create_mchat(name)
    end
  end

  def mchat_name
    return 'MCHAT18' if appointment_type.athena_id == AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[18]
    return 'MCHAT24' if appointment_type.athena_id == AppointmentType::WELL_VISIT_ATHENA_ID_FOR_VISIT_AGE[24]
    return 'MCHAT18' if (milestone_from_birth?(18, 1) && appointment_type.athena_id == AppointmentType::WELL_VISIT_TYPE_ATHENA_ID)
    return 'MCHAT24' if (milestone_from_birth?(24, 1) && appointment_type.athena_id == AppointmentType::WELL_VISIT_TYPE_ATHENA_ID)
  end

  def create_mchat(name)
    return if  UserSurvey.includes(:survey).where(patient: patient, survey:{name: name}).length > 0
    time_to_apppointment = (Time.current - start_datetime)
    primary_guardian = patient.family.primary_guardian
    if time_to_apppointment < 3.days && time_to_apppointment > 0 && survey = Survey.find_by(name: name)
      UserSurvey.create_and_notify(primary_guardian, patient, survey)
    else
      UserSurvey.delay(run_at: time_to_apppointment - 3.days, queue: 'survey', owner: primary_guardian).create_and_notify(primary_guardian, patient, survey)
    end
  end
end
