class Practice < ActiveRecord::Base
  belongs_to :appointments_sync_job, class_name: Delayed::Job
  has_many :guardians, ->{ guardians }, class_name: "User"
  has_many :staff, ->{ staff }, class_name: "User"
  has_many :providers
  has_many :appointments, -> { where appointment_status: AppointmentStatus.booked }
  has_many :practice_schedules
  validates :name, presence: true
  after_commit :subscribe_to_athena, on: :create

  def self.flatiron_pediatrics
    self.find_by(athena_id: 1)
  end

  def in_office_hours?
    unless $redis.get('start_time') || $redis.get('end_time')
      start_time, end_time = convert_time
      next_day = Date.tomorrow.to_datetime.to_i
      $redis.set('start_time', start_time.to_i); $redis.expireat('start_time', next_day)
      $redis.set('end_time', end_time.to_i); $redis.expireat('end_time', next_day)
    end
    start_time, end_time = $redis.get('start_time').to_i, $redis.get('end_time').to_i
    start_time <= Time.current.to_i && end_time >= Time.current.to_i
  end

  def subscribe_to_athena
    SyncPracticeJob.new(self).subscribe_if_needed run_at: Time.now
  end

  def on_call_providers
    staff.joins(:staff_profile).where(staff_profile: { on_call: true })
  end

  def available?
    on_call_providers.count > 0
  end

  def broadcast_practice_availability
    begin
      Pusher.trigger("private-practice", :availability_changed, { practice_id: id })
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end

  def active_schedule
    practice_schedules.where(active: true).first
  end


  def holiday?(date)
    date.saturday? || date.sunday? || holidays.include?(date.holidays(:us).first.try(:[], :name))
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
