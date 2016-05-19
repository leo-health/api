class AnalyticsController < ApplicationController
  before_action :set_date_range, only: [:index]

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
    ]
  end

  def practice_engagement
    [
      ['# of patients who had at least 1 appointment in the last 18 months', Analytics.patients_with_appointments_in(18.months.ago..Time.now).count],
      ['# of new patients enrolled in practice', month_format_keys(Analytics.new_patients_enrolled_in_practice) ]
    ]
  end

  def scheduling_engagement
    [
      ['# of visits scheduled from app', Analytics.visits_booked_by(Role.guardian, @stats_time_range).count],
      ['# of visits scheduled from app + practice (total)', Analytics.appointments_count(@stats_time_range)]
    ]
  end

  def messaging_engagement
    [
      ['# of guardians that sent a message', Analytics.guardians_who_sent_messages(@stats_time_range).count]
    ]
  end

  def child_health_record_engagement
    [
      ['# of times guardian visited record', 'n/a'],
      ['% of app active guardians that visited hr', 'n/a']
    ]
  end

  def response_time_metrics
    @conversation_opened_at = Hash.new { |h,k| h[k] = [] }
    time_to_case_close = calculate_time_to_case_close
    average_close_time = array_average(time_to_case_close)
    median_close_time = array_median(time_to_case_close)
    [
      ['#Avg. Time to Case Close', "#{average_close_time} minutes"],
      ['#Med. Time to Case Close', "#{median_close_time} minutes"]
    ]
  end

  def provider_app_engagement
    escalation_notes_created = EscalationNote.where.not(note: nil).count
    closure_notes_created = ClosureNote.where.not(note: nil).count
    total_notes_created = escalation_notes_created + closure_notes_created
    average_assign_time = array_average(calculate_time_to_case_assigned)
    [
      ['# of Cases Assigned', EscalationNote.count],
      ['# of Cases Closed', ClosureNote.count],
      ['# of Notes Created', total_notes_created],
      ['Time to Assigned', "#{average_assign_time} minutes"] #Time to Assigned - first message after last closed to assigned timestamp before closed
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

  def array_average(arr)
    return "n/a" if arr.size < 1
    average_in_seconds = arr.inject{ |sum, el| sum + el }.to_f / arr.size
    (average_in_seconds / 60).round(1)
  end

  def array_median(arr)
    return 'n/a' if arr.size < 1
    sorted = arr.sort
    mid = arr.size / 2
    median_in_seconds = arr.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1])
    (median_in_seconds / 60).round(1)
  end

  def calculate_time_to_case_close
    time_to_case_close = []
    Conversation.includes(:closure_notes, :messages).each do |conversation|
      previous_closure_note = false
      @conversation_opened_at[conversation.id] << conversation.created_at
      conversation.closure_notes.each do |closure_note|
        if previous_closure_note
          message = conversation.messages.where('created_at < ?', closure_note.created_at).order('created_at DESC').first
          @conversation_opened_at[conversation.id] << message.created_at
          time_to_case_close << closure_note.created_at - message.created_at
        else
          time_to_case_close << closure_note.created_at - conversation.created_at
        end
        previous_closure_note = closure_note
      end
    end
    time_to_case_close
  end

  def calculate_time_to_case_assigned
    time_to_assigned = []
    Conversation.includes(:escalation_notes, :messages).each do |conversation|
      conversation.escalation_notes.each do |escalation_note|
        last_open_at = false
        @conversation_opened_at[conversation.id].reverse_each do |opened_at|
          if opened_at < escalation_note.created_at
            last_open_at = opened_at
            next
          end
        end
        time_to_assigned << escalation_note.created_at - last_open_at
      end
    end
    time_to_assigned
  end

  def month_format_keys(datetime_to_number_hash)
    datetime_to_number_hash.transform_keys{|k| k.strftime('%Y-%m')}
  end


  protected  ## Protected methods until EOF

  # Reads a desired date range for the stats from provided params
  # if date is missing assume range from year 2000 to tomorrow
  def set_date_range
    begin_date = Date.strptime(params[:stats_begin_date], '%m-%d-%Y') rescue Date.new(2000)
    end_date = Date.strptime(params[:stats_end_date], '%m-%d-%Y') rescue Date.tomorrow
    @stats_time_range = begin_date..end_date
  end
end
