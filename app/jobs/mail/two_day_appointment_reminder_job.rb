class TwoDayAppointmentReminderJob < Struct.new(:user_id, :appointment_id)
  def self.send(user_id, appointment_id)
    Delayed::Job.enqueue(new(user_id, appointment_id))
  end

  def perform
    user = User.find_by_id(user_id)
    appointment = Appointment.find_by_id(appointment_id)
    if user.try(:complete?)
      UserMailer.complete_user_two_day_appointment_reminder(user, appointment).deliver if appointment
    else
      UserMailer.incomplete_user_two_day_appointment_reminder(user, appointment).deliver if user && appointment
    end
  end

  def queue_name
    'notification_email'
  end
end
