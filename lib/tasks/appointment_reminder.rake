namespace :appointment do
  desc "send user a reminder 5 days prior to upcoming appointment"
  task five_day_notification: :environment do
    Appointment.where(:start_datetime => 5.days.from_now.utc..6.days.from_now.utc).find_each do |appointment|
      created_job = UserMailer.delay.five_day_appointment_reminder(appointment.booked_by)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send user a reminder for his appointment today"
  task one_day_notification: :environment do
    Appointment.where(:start_datetime => Time.now.utc..1.days.from_now.utc).find_each do |appointment|
      created_job = UserMailer.delay.five_day_appointment_reminder(appointment.booked_by)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end
end
