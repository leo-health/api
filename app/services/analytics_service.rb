require 'csv'

class AnalyticsService

  #### Class methods - stats data queries

  class << self
    # @param [Range<Time>] time_range Only Patient-s with Appointment-s within that time range will be retrieved
    # @return [ActiveRecord::Relation<Patient>] Patient-s with Appointment-s in the given time range
    def patients_with_appointments(time_range: nil)
      #patients = Patient.joins(:appointments)
      #patients = patients.where(appointments: {start_datetime: time_range}) if time_range.present?
      #patients.uniq(:id)
      appts = Appointment.pluck(:patient_id)
      appts.uniq
    end

    # @return [Array<Hash{Time => Integer}>]
    def new_patients_enrolled_monthly
      Patient.group("date_trunc('month', created_at)").size
    end

    # @param [Role] role Limit only to Appointment-s by User-s with that role
    # @param [Range<Time>] time_range Only Appointment-s starting within that time rage will be retrieved
    # @param [Boolean] same_day_only If true, returns only Appointment-s scheduled for the same day
    # @return [Enumerable<Appointment>]
    def appointments_booked(time_range: nil, role: nil, same_day_only: false)
      appointments = Appointment.all
      appointments = appointments.where(created_at: time_range) if time_range.present?
      appointments = appointments.includes(:booked_by_user).where(booked_by_user: {role_id: role.id}) if role.present?
      #appointments = appointments.for_analytics
      appointments = appointments.where.not(appointment_status: 6)
      appointments = appointments.select { |appointment| appointment.created_at.to_date === appointment.start_datetime.to_date } if same_day_only
      appointments
    end

    # @param [Role] role Limit only to Appointment-s by User-s with that role
    # @param [Range<Time>] time_range Only Appointment-s starting within that time rage will be retrieved
    # @param [Boolean] same_day_only If true, returns only Appointment-s scheduled for the same day
    # @return [Enumerable<Appointment>]
    def appointments_cancelled(time_range: nil, role: nil, same_day_only: false)
      cancelled = Appointment.all
      cancelled = cancelled.where(created_at: time_range) if time_range.present?
      cancelled = cancelled.includes(:booked_by_user).where(booked_by_user: {role_id: role.id}) if role.present?
      cancelled = cancelled.select { |appointment| appointment.created_at.to_date === appointment.start_datetime.to_date } if same_day_only
      cancelled = cancelled.where(appointment_status: 6)
      cancelled
    end

     # @param [Role] role Limit only to Appointment-s by User-s with that role
    # @param [Range<Time>] time_range Only Appointment-s starting within that time rage will be retrieved
    # @param [Boolean] same_day_only If true, returns only Appointment-s scheduled for the same day
    # @return [Enumerable<Appointment>]
    def appointments_rescheduled(time_range: nil, role: nil, same_day_only: false)
      rescheduled = Appointment.all
      rescheduled = rescheduled.where(created_at: time_range) if time_range.present?
      rescheduled = rescheduled.includes(:booked_by_user).where(booked_by_user: {role_id: role.id}) if role.present?
      rescheduled = rescheduled.select { |appointment| appointment.created_at.to_date === appointment.start_datetime.to_date } if same_day_only
      rescheduled = rescheduled.where.not(rescheduled_id: nil)
      rescheduled
    end

    # @param [Range<Time>] time_range Only Guardian-s who sent Message-s within that time range will be retrieved
    # @return [ActiveRecord::Relation<User>]
    def guardians_who_sent_messages(time_range: nil)
      guardians = User.guardians.joins(:sent_messages)
      guardians = guardians.where(sent_messages: {created_at: time_range}) if time_range.present?
      guardians.distinct
    end


    # @param [Range<Time>] time_range Only Message-s sent within the time range will be retrieved
    # @return [Enumerable<Message>]
    def total_messages_sent(time_range: nil)
      # @param [Range<Time>] time_range Only Guardian-s who sent Message-s within that time range will be retrieved
      messages = Message.all
      messages = messages.where.not(sender_id: 5)
      messages = messages.where(created_at: time_range) if time_range.present?
      messages
    end

    # @param [Range<Time>] time_range Only cases fully contained within that time range will be counted
    # @return [Array<Numeric>]
    def cases_times_in_seconds(time_range: nil)
      cases_times = []

      conversations = Conversation.includes(:closure_notes, :messages)
      conversations = conversations.where(closure_notes: { created_at: time_range }) if time_range.present?
      conversations.find_each do |conversation|
        cases_times.concat conversation_cases_times(conversation, time_range: time_range)
      end

      cases_times
    end


    protected

    # Durations of all 'cases' in a given conversation, optionally only ones fully contained within a given time_range
    # @param [Conversation] conversation
    # @param [Range<Time>] time_range Only cases fully contained within that time range will be counted
    # @return [Array<Numeric>] Times in seconds
    def conversation_cases_times(conversation, time_range: nil)
      closure_notes = conversation.closure_notes.reload.sort_by(&:created_at)  # Note the '#reload' here. Needed to obtain 'last_closure_note_before_time_range'
      messages = conversation.messages.sort_by(&:created_at)
      if time_range.present?
        filtered_closure_notes_and_messages = messages_and_closure_times_within_time_range(time_range, closure_notes, messages)
        closure_notes, messages = filtered_closure_notes_and_messages[:closure_notes], filtered_closure_notes_and_messages[:messages]
      end

      return [] if closure_notes.empty? || messages.empty?

      cases_times = []

      messages_enum = messages.to_enum
      message = messages_enum.next
      closure_notes.each do |closure_note|
        case_time = (closure_note.created_at - message.created_at).to_f
        cases_times << case_time unless case_time < 0  # The comparison is only a safety check - should never happen with proper data

        # Ignore all subsequent messages before the current closure_note
        begin
          message = messages_enum.next while message.created_at <= closure_note.created_at
        rescue StopIteration
          break
        end
      end

      cases_times
    end

    # Filters a set of Message-s and ClosureNote-s to return only those that constitute to 'cases' contained within a given time_range
    # @param [Range<Time>] time_range
    # @param [Array<ClosureNote>] closure_notes Must be sorted by 'created_at'!
    # @param [Array<Message>] messages Must be sorted by 'created_at'!
    # @return [{closure_notes: Array<ClosureNote>, messages: Array<Message>}]
    def messages_and_closure_times_within_time_range(time_range, closure_notes, messages)
      last_closure_note_before_time_range = closure_notes.reverse.find { |closure_note| closure_note.created_at < time_range.begin }
      last_message_before_time_range = messages.reverse.find { |message| message.created_at < time_range.begin }

      closure_notes.reject! { |closure_note| closure_note.created_at < time_range.begin || closure_note.created_at > time_range.end }
      messages.reject! { |messages| messages.created_at < time_range.begin || messages.created_at > time_range.end }

      # If there was a message *before* time_range associated with the first closure_note *within* time_range,
      # then the resulting 'case' is outside the range. Thus discard that closure_note and all messages before it.
      if last_message_before_time_range.present? &&
          (last_closure_note_before_time_range.nil? || last_message_before_time_range.created_at > last_closure_note_before_time_range.created_at)
        discarded_closure_note = closure_notes.shift
        messages.reject! { |message| message.created_at <= discarded_closure_note.created_at }
      end

      # Discard all closure_notes that do not have preceding messages
      return { closure_notes: [], messages: [] } if messages.empty?
      first_message_created_at = messages.first.created_at
      closure_notes.reject! { |closure_note| closure_note.created_at < first_message_created_at }

      # Discard all messages that do not have following closure_notes
      return { closure_notes: [], messages: [] } if closure_notes.empty?
      last_closure_note_created_at = closure_notes.last.created_at
      messages.reject! { |message| message.created_at > last_closure_note_created_at }

      { closure_notes: closure_notes, messages: messages }
    end
  end


  #### Instance Methods & Attributes

  attr_reader :time_range

  def initialize(time_range = nil)
    @time_range = time_range
  end


  ## Data retrieval - adapters for class methods

  def new_patients_enrolled_monthly
    @new_patients_enrolled_monthly ||= AnalyticsService.new_patients_enrolled_monthly.transform_keys { |k| k.strftime('%Y-%m') }
  end
  def patients_with_appointments
    @patients_with_appointments ||= AnalyticsService.patients_with_appointments(time_range: time_range)
  end
  def appointments_booked(role: nil, same_day_only: false)
    AnalyticsService.appointments_booked(time_range: time_range, role: role, same_day_only: same_day_only)
  end
  def appointments_cancelled(role: nil, same_day_only: false)
    AnalyticsService.appointments_cancelled(time_range: time_range, role: role, same_day_only: same_day_only)
  end
  def appointments_rescheduled(role: nil, same_day_only: false)
    AnalyticsService.appointments_rescheduled(time_range: time_range, role: role, same_day_only: same_day_only)
  end
  def guardians_who_sent_messages
    @guardians_who_sent_messages ||= AnalyticsService.guardians_who_sent_messages(time_range: time_range)
  end
  def total_messages_sent(time_range: nil)
    AnalyticsService.total_messages_sent(time_range: time_range)
  end
  def cases_times_in_seconds
    @cases_times_in_seconds ||= AnalyticsService.cases_times_in_seconds(time_range: time_range)
  end


  ## Additional stats calculations and helpers

  def median_case_time_in_minutes
    return 'n/a' if cases_times_in_seconds.empty?

    sorted_array = cases_times_in_seconds.sort
    mid_element_index = cases_times_in_seconds.size / 2
    median_in_seconds = if cases_times_in_seconds.length.odd?
                          sorted_array[mid_element_index]
                        else
                          (sorted_array[mid_element_index] + sorted_array[mid_element_index - 1]) / 2
                        end
    (median_in_seconds / 60).round(1)
  end

  def average_case_time_in_minutes
    return 'n/a' if cases_times_in_seconds.empty?

    average_in_seconds = cases_times_in_seconds.sum / cases_times_in_seconds.size
    (average_in_seconds / 60).round(1)
  end


  ## Final stats containers

  # @return [Hash<String, Hash<String, #to_s>>]
  def single_value_stats
    @single_value_stats ||= {
      'Schedule Engagement' => {
        '# of visits scheduled from app' => appointments_booked(role: Role.guardian).size,
        '# of visits cancelled from app' => appointments_cancelled(role: Role.guardian).size - appointments_rescheduled(role: Role.guardian).size,
        '# of visits rescheduled from app' => appointments_rescheduled(role: Role.guardian).size,
      },
      'Appointment Engagement' => {
        '# of same day appointments from app' => appointments_booked(role: Role.guardian, same_day_only: true).size,
      },
      'Message Engagement' => {
        '# of guardians that sent a message' => guardians_who_sent_messages.size,
        '# of total messages sent' => total_messages_sent.size
      },
      'Response Time Metric' => {
        'Average Time to Case Close (minutes)' => average_case_time_in_minutes,
        'Median Time to Case Close (minutes)'=> median_case_time_in_minutes
      }
    }
  end

  # @return [Hash<String, #to_s>]
  def practice_engagement_single_value_stats
    @practice_engagement_single_value_stats ||= {
      '# of parents who booked at least 1 appointment through the app' => patients_with_appointments.size
    }
  end

  # @return [Hash<String, Hash<>>]
  #def practice_engagement_monthly_stats
   # @practice_engagement_monthly_stats ||= {
    #  '# of new patients enrolled in practice monthly' => new_patients_enrolled_monthly
    #}
  #end


  ## Formatters

  # @return [CSV]
  def to_csv
    CSV.generate do |csv|
      # Single-value stats
      stats_hash = {}.merge(practice_engagement_single_value_stats)
      single_value_stats.each_value { |value| stats_hash.merge!(value) }
      stats_hash.to_a.each { |stat_item| csv << stat_item }

      # Monthly stats
      stat_name, data = practice_engagement_monthly_stats.to_a.first
      data = data.to_a
      csv << [stat_name] + data.shift  # First data point added next to the stat name
      data.each { |datum| csv << [''] + datum }  # Following data points added with a one column offset
    end
  end


end
