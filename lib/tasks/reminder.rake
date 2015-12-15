namespace :notification do
  desc "send user a reminder 5 days prior to upcoming appointment"
  task five_day_prior_appointment: :environment do
    Appointment.where(start_datetime: 5.days.from_now.utc..6.days.from_now.utc).find_each do |appointment|
      booker = appointment.booked_by
      created_job = UserMailer.delay.five_day_appointment_reminder(booker)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send user a reminder for his appointment today"
  task one_day_prior_appointment: :environment do
    Appointment.where(start_datetime: Time.now.utc..1.day.from_now.utc).find_each do |appointment|
      created_job = UserMailer.delay.same_day_appointment_reminder(appointment.booked_by)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send guardian email on their children birthday"
  task patient_birthday: :environment do
    Patient.includes(family: :guardians).where(birth_date: Time.now.utc..1.day.from_now.utc).find_each do |patient|
      patient.family.guardians.each do |guardian|
        created_job = UserMailer.delay.patient_birthday(guardian)
        if created_job.valid?
          print "*"
        else
          print "x"
        end
      end
    end
  end

  desc "send guardian account confirmation reminder one day before expiration"
  task account_confirmation_reminder: :environment do
    User.joins(:role).where(roles: { name: "guardian" }, confirmed_at: nil, confirmation_sent_at: Time.now.utc - 6.days..Time.now.utc - 5.days ).find_each do |user|
      created_job = UserMailer.delay.account_confirmation_reminder(user)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send email digest to conversation owner about escalated conversations"
  task escalated_covnersation_email_digest: :environment do
    User.staff.each do |staff|
      count = staff.escalated_conversations.count
      next if count == 0
      created_job = UserMailer.delay.unaddressed_conversations_digest(staff, count, :escalated)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end


  desc "send email digest to customer service about open conversations"
  task open_conversation_email_digest: :environment do
    User.joins(:role).where(roles: {name: "customer_service"}).each do |cs_user|
      count = Conversation.where(state: :open).count
      next if count == 0
      created_job = UserMailer.delay.unaddressed_conversations_digest(cs_user, count, :open)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end
end