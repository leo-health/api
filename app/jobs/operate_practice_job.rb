class OperatePracticeJob < Struct.new(:practice_id)
  attr_reader :practice, :operation_type, :v, :e

  def initialize(practice_id, operation_type=nil)
    @practice = Practice.find_by(id: practice_id)
    @operation_type = operation_type
    @v = User.find_by(email: "victoria@flatironpediatrics.com")
    @e = User.find_by(email: "erin@flatironpediatrics.com")
  end

  def self.start(practice_id)
    open_job, close_job, switch_v_e_off_job = new(practice_id, :open), new(practice_id, :close), new(practice_id)
    return unless practice = open_job.practice
    Delayed::Job.enqueue open_job, run_at: practice.active_schedule.start_time_for_date(Date.today)
    Delayed::Job.enqueue close_job, run_at: practice.active_schedule.end_time_for_date(Date.today)
    Delayed::Job.enqueue switch_v_e_off_job, run_at: DateTime.current.change(hour: 21)
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

  private

  def close_vi_and_er
    [v, e].each do |provider|
      if provider.staff_profile.try(:update_attributes, {sms_enabled: false, on_call: false})
        broadcast_oncall_change([provider.id], 'off-call')
      end
    end
  end

  def start_after_office_hours
    staff = practice.staff - [v, e]
    if StaffProfile.where(staff: staff).update_all(sms_enabled: false, on_call: false) > 0
      broadcast_oncall_change(staff.map(&:id), 'off-call')
    end
    [v, e].each{|provider| provider.staff_profile.update_attributes(sms_enabled: true, on_call: true)}
  end

  def start_in_office_hours
    if StaffProfile.where(staff: practice.staff).update_all(sms_enabled: false, on_call: true) > 0
      practice.broadcast_practice_availability
      broadcast_oncall_change(practice.staff.map(&:id), 'on-call')
    end
  end

  def broadcast_oncall_change(ids, event)
    begin
      Pusher.trigger("staff", :oncall_change, { staff_ids:  ids, event: event })
    rescue Pusher::Error => e
      Rails.logger.error "Pusher error: #{e.message}"
    end
  end
end
