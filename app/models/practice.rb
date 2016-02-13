class Practice < ActiveRecord::Base
  has_many :staff, ->{ where role_id: [2, 3, 5] }, class_name: "User"
  has_many :guardians, ->{ where role_id: 4 }, class_name: "User"
  has_many :appointments, -> { where appointment_status: AppointmentStatus.booked }
  has_many :practice_schedules

  validates :name, presence: true

  def in_office_hour?
    start_time, end_time = convert_time
    (start_time..end_time).cover?(Time.current)
  end

  private

  def convert_time
    active_schedule = practice_schedules.find_by(active: true)
    date_today = Time.zone.now.to_date
    wday = date_today.strftime("%A").downcase
    start_time = active_schedule.public_send("#{wday}_start_time")
    end_time = active_schedule.public_send("#{wday}_end_time")
    start_time = DateTime.parse(Time.zone.parse("#{date_today.to_date.inspect} #{start_time}").to_s).in_time_zone
    end_time = DateTime.parse(Time.zone.parse("#{date_today.to_date.inspect} #{end_time}").to_s).in_time_zone
    return start_time, end_time
  end
end
