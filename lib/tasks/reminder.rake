namespace :notification do
  desc "send user a reminder for his appointment in two days"
  task complete_user_two_day_prior_appointment: :environment do
    in_two_day = 1.day.from_now.utc..2.day.from_now.beginning_of_day.utc
    Appointment.where(appointment_status: AppointmentStatus.future, start_datetime: in_two_day)
      .includes(patient: { family: :all_guardians }).find_each do |appointment|
        if family = appointment.patient.try(:family)
          family.all_guardians.each do |guardian|
            created_job = TwoDayAppointmentReminderJob.send(guardian.id, appointment.id)
            if created_job.valid?
              print "*"
            else
              print "x"
            end
          end
        end
      end
  end

  desc "send guardian email on their children birthday"
  task patient_birthday: :environment do
    in_one_day = Time.now.utc..1.day.from_now.utc
    Patient.includes(family: :guardians).where(birth_date: in_one_day).find_each do |patient|
      patient.family.guardians.each do |guardian|
        created_job = PatientBirthdayJob.send(guardian.id. patient.id)
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
    in_five_days = Time.now.utc - 6.days..Time.now.utc - 5.days
    User.complete.where(role: Role.guardian, confirmed_at: nil, confirmation_sent_at: in_five_days).find_each do |user|
      created_job = AccountConfirmationReminderJob.send(user.id)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send email digest to conversation owner about escalated conversations"
  task escalated_conversation_email_digest: :environment do
    User.staff.each do |staff|
      count = staff.escalation_notes.select do |escalation_note|
        escalation_note.active?
      end.count

      next if count == 0
      created_job = UnaddressedConversationDigestJob.send(staff.id, count, :escalated)
      if created_job.valid?
        print "*"
      else
        print "x"
      end
    end
  end

  desc "send pusher message to notify practice availabilty at open and close time of a practice"
  task practice_availability_change: :environment do
    Practice.all.each do |practice|
      next if practice.holiday?(Date.today)
      OperatePracticeJob.start(practice.id)
    end
  end
end
