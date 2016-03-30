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
    [
      ["#App Accounts Enrolled (login + password)", Enrollment.count],
      ["#App Accounts Completed (new families?)", Enrollment.count - User.guardians.count]
    ]
  end

  def practice_engagement
    active_patient_count = Vital.where("taken_at > ?", Time.now-18.months).joins(:patient).uniq.count
    active_patient_percent = active_patient_count.to_f / Patient.count.to_f * 100.00
    [
      [ '# of Families in Practice (BOM)', Family.count ],
      [ '# of Patients in Practice (BOM)', Patient.count ],
      [ '# of Active Patients in Practice', active_patient_count ],
      [ '% of Active Patients in Practice', "#{active_patient_percent}%" ]
    ]
  end

  def scheduling_engagement
    visits_from_app = Appointment.includes(:booked_by).where(booked_by: { role_id: Role.guardian.id }).count
    visits_from_app_percent = visits_from_app.to_f / Appointment.count.to_f * 100.00
    [
      ['# of visits scheduled from app', visits_from_app],
      ['# of visits scheduled from app + practice (total)', Appointment.count],
      ['% of total visits scheduled from app', "#{visits_from_app_percent}%"],
      ['% of App Active guardians that scheduled', 'n/a']
    ]
  end

  def messaging_engagement
    guardians_sent_message = User.joins(:sent_messages).guardians.count
    [
      ['# of guardians that sent a message', guardians_sent_message],
      ['% of App Active guardians that messaged', 'n/a']
    ]
  end

  def child_health_record_engagement
    [
      ['# of times guardian visited record', 'n/a'],
      ['% of app active guardians that visited hr', 'n/a']
    ]
  end

  def response_time_metrics
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
    [
      ['#Avg. Time to Case Close', 'n/a'], #Avg. Time to Case Close - first message after last closed and last closed timestamp - postgres mapreduce
      ['#Med. Time to Case Close', 'n/a'], #Med. Time to Case Close - mark as suboptimal, temporary in memory store
    ]
  end

  def provider_app_engagement
    escalation_notes_created = EscalationNote.where.not(note: nil).count
    closure_notes_created = ClosureNote.where.not(note: nil).count
    total_notes_created = escalation_notes_created + closure_notes_created
    [
      ['# of Cases Assigned', EscalationNote.count],
      ['# of Cases Closed', ClosureNote.count],
      ['# of Notes Created', total_notes_created],
      ['Time to Assigned', 'n/a'] #Time to Assigned - first message after last closed to assigned timestamp before closed
    ]
  end

  def appointment_enagament
    same_day_appointments = Appointment.select{ |app| app.created_at.to_date === app.start_datetime.to_date }.count
    [
      ['# of no show appointments', 'n/a'],
      ['# of same day appointments', same_day_appointments],
      ['# of late to appointment appointments', 'n/a']
    ]
  end
end
