class SameDayAppointmentReminderJob < Struct.new(:user_id)
  def self.send(user_id)
    Delayed::Job.enqueue(new(user_id))
  end

  def perform
    user = User.find_by_id(user_id)
    UserMailer.same_day_appointment_reminder(user).deliver if user
  end
end