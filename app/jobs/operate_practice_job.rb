class OperatePracticeJob < Struct.new(:practice_id)
  attr_reader :practice, :operation_type, :v, :e

  def initialize(practice_id, operation_type=nil)
    @practice = Practice.find_by(id: practice_id)
    @operation_type = operation_type
    @v = User.find_by(email: "victoria@flatironpediatrics.com")
    @e = User.find_by(email: "erin@flatironpediatrics.com")
  end

  def self.start(practice_id)
    open_job, close_job = new(practice_id, :open), new(practice_id, :close)
    return unless practice = open_job.practice
    Delayed::Job.enqueue open_job, run_at: practice.active_schedule.start_time_for_date(Date.today)
    Delayed::Job.enqueue close_job, run_at: Time.now, owner_type: :close
  end

  def perform
    if operation_type == :close
      start_after_office_hours
    elsif operation_type == :open
      start_in_office_hours
    else
      close_vi_and_er
    end
  end

  def after(job)
    Delayed::Job.enqueue new(practice_id), run_at: DateTime.now.change(hour: 21) if job.owner_type == "close"
  end

  private

  def close_vi_and_er
    [v, e].each do |provider|
      if staff_profile = provider.staff_profile
        staff_profile.update_attributes(sms_enabled: false, on_call: false)
      end
    end
  end

  def start_after_office_hours
    staff = practice.staff - [v, e]
    StaffProfile.where(staff: staff).update_all(sms_enabled: false, on_call: false) > 0
    Pusher.trigger("practice", :practice_hour, { practice_id: practice.id, status: 'closed' })
  end

  def start_in_office_hours
    if StaffProfile.where(staff: practice.staff).update_all(sms_enabled: false, on_call: true) > 0
      practice.broadcast_practice_availability
    end
    Pusher.trigger("practice", :practice_hour, { practice_id: practice.id, status: 'open' })
  end
end
