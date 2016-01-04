class RemindScheduleAppointmentJob < Struct.new(:user_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id), run_at: 48.hours.from_now.utc)
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.remind_schedule_appointment(user).deliver if user
  end
end
