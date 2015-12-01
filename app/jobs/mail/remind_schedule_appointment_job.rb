class RemindScheduleAppointmentJob < Struct.new(:user_id)
  def perform
    user = User.find_by_id(user_id)
    UserMailer.remind_schedule_appointment(user).deliver if user
  end

  def send
    Delayed::Job.enqueue self, run_at: 48.hours.from_now.utc
  end
end
