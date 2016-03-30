class AnalyticsController < ApplicationController
  def index
    @analytics = {
      registration_engagement: registration_engagement,
      practice_engagement: practice_engagement,
      scheduling_engagement: scheduling_engagement,
      messaging_engagement: messaging_engagement,
      child_health_record_engagement: child_health_record_engagement,
      response_time_metrics: response_time_metrics,
      provider_app_engagement: provider_app_engagement,
      appointment_enagament: appointment_enagament
    }
  end

  def registration_engagement
    #App Accounts Enrolled (login + password)
    #App Accounts Completed (new families?)
    [
      ["#App Accounts Enrolled (login + password)", Enrollment.count],
      ["#App Accounts Completed (new families?)", Enrollment.count - User.guardians.count]
    ]
  end

  def practice_engagement
    # of Families in Practice (BOM)
    # of Patients in Practice (BOM)
    # of Active Patients in Practice(vital taken_at timestamp)
    # % of Active Patients in Practice
    active_patient_count = Vital.where("taken_at > ?", Time.now-18.months).joins(:patient).uniq.count
    active_patient_percent = active_patient_count.to_f / Patient.count.to_f * 100.00
    [Family.count, Patient.count, active_patient_count, active_patient_percent]
  end

  def scheduling_engagement
    # of visits scheduled from app(by checking booked by)
    # of visits scheduled from app + practice (total)
    # % of total visits scheduled from app
    # % of App Active guardians that scheduled
    visits_from_app = Appointment.includes(:booked_by).where(booked_by: { role_id: Role.guardian.id }).count
    visits_from_app_percent = visits_from_app.to_f / Appointment.count.to_f * 100.00
    [visits_from_app, Appointment.count, visits_from_app_percent, 'n/a']
  end

  def messaging_engagement
    # of guardians that sent a message
    # % of App Active guardians that messaged
    guardians_sent_message = User.joins(:sent_messages).guardians.count
    [guardians_sent_message, 'n/a']
  end

  def child_health_record_engagement
    # of times guardian visited record
    # % of app active guardians that visited hr
    ['n/a', 'n/a']
  end

  def response_time_metrics
    #Avg. Time to Case Close - first message after last closed and last closed timestamp - postgres mapreduce
    #Med. Time to Case Close - mark as suboptimal, temporary in memory store
    # Conversation.all.each do |conversation|
    #   previous_closure_note = false
    #   conversation.closure_notes.each do |note|
    #     if previous_closure_note
    #       last_message = conversation.messages.where('created_at > ?', previous_closure_note.created_at).first
    #       last_opened_
    #     else
    #       last_opened_at = conversation.created_at
    #     end
    #   end
    # end
    ['n/a', 'n/a']
  end

  def provider_app_engagement
    #Cases Assigned
    #Cases Closed
    # # of Notes Created
    #Time to Assigned - first message after last closed to assigned timestamp before closed
    escalation_notes_created = EscalationNote.where.not(note: nil).count
    closure_notes_created = ClosureNote.where.not(note: nil).count
    total_notes_created = escalation_notes_created + closure_notes_created
    [EscalationNote.count, ClosureNote.count, total_notes_created, 'n/a']
  end

  def appointment_enagament
    # of no show appointments
    # of same day appointments
    # of late to appointment appointments
    same_day_appointments = Appointment.select{ |app| app.created_at.to_date === app.start_datetime.to_date }.count
    ['n/a', same_day_appointments, 'n/a']
  end
end
