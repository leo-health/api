class Practice < ActiveRecord::Base
  belongs_to :appointments_sync_job, class_name: Delayed::Job
  has_many :staff, ->{ clinical_staff }, class_name: "User"
  has_many :guardians, ->{ guardians }, class_name: "User"
  has_many :appointments, -> { where appointment_status: AppointmentStatus.booked }
  has_many :practice_schedules

  validates :name, presence: true

  after_commit :subscribe_to_athena, on: :create

  def self.flatiron_pediatrics
    self.find(1)
  end

  def in_office_hour?
    start_time, end_time = convert_time
    (start_time..end_time).cover?(Time.current)
  end


  def subscribe_to_athena
    SyncAppointmentsJob.subscribe_if_needed self
  end

  def get_appointments_from_athena
    SyncServiceHelper::Syncer.instance.sync_athena_appointments_for_practice self
  end

  private

  def convert_time
    active_schedule = practice_schedules.find_by(active: true)
    date_today = Time.zone.now.to_date
    wday = date_today.strftime("%A").downcase
    start_time = active_schedule.public_send("#{wday}_start_time")
    end_time = active_schedule.public_send("#{wday}_end_time")
    start_time = Time.zone.parse("#{date_today.to_date.inspect} #{start_time}").to_datetime
    end_time = Time.zone.parse("#{date_today.to_date.inspect} #{end_time}").to_datetime
    return start_time, end_time
  end
end
