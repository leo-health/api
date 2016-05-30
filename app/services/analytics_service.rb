require 'csv'

class AnalyticsService

  #### Class methods - stats data queries

  class << self
    # @param [Range<Time>] time_range Only Patient-s with Appointment-s within that time range will be retrieved
    # @return [ActiveRecord::Relation<Patient>] Patient-s with Appointment-s in the given time range
    def patients_with_appointments(time_range: nil)
      patients = Patient.joins(:appointments)
      patients = patients.where(appointments: {start_datetime: time_range}) if time_range.present?
      patients.uniq(:id)
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
      appointments = appointments.select { |appointment| appointment.created_at.to_date === appointment.start_datetime.to_date } if same_day_only
      appointments
    end

    # @param [Range<Time>] time_range Only Guardian-s who sent Message-s within that time range will be retrieved
    # @return [ActiveRecord::Relation<User>]
    def guardians_who_sent_messages(time_range: nil)
      guardians = User.guardians.joins(:sent_messages)
      guardians = guardians.where(sent_messages: {created_at: time_range}) if time_range.present?
      guardians.distinct
    end

    # @return [Array<Numeric>]
    def cases_times_in_seconds(time_range: nil)
      [].tap do |cases_times|
        conversations = Conversation.includes(:closure_notes, :messages)
        conversations = conversations.where(closure_notes: { created_at: time_range }) if time_range.present?

        conversations.find_each do |conversation|
          closure_notes = conversation.closure_notes.sort_by(&:created_at)
          messages = conversation.messages.sort_by(&:created_at)
          if time_range.present?
            closure_notes = closure_notes.select { |closure_note| closure_note.created_at > time_range.begin && closure_note.created_at < time_range.end }
            messages = messages.select { |messages| messages.created_at > time_range.begin && messages.created_at < time_range.end }
          end
          next if closure_notes.empty? || messages.empty?

          conversation_cases_times = []

          messages_enum = messages.to_enum
          message = messages_enum.next
          closure_notes.each do |closure_note|
            next unless message.try(:created_at) < closure_note.created_at  # Case has begun before the time_range, thus ignore it
            conversation_cases_times << (closure_note.created_at - message.created_at).to_f

            # Ignore all subsequent messages before the current closure_note
            begin
              message = messages_enum.next while closure_note.created_at > message.created_at
            rescue StopIteration
              break
            end
          end

          cases_times.concat(conversation_cases_times)
        end
      end
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
  def guardians_who_sent_messages
    @guardians_who_sent_messages ||= AnalyticsService.guardians_who_sent_messages(time_range: time_range)
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
        '# of visits scheduled from app + practice (total)' => appointments_booked.size
      },
      'Appointment Engagement' => {
        '# of same day appointments from app' => appointments_booked(role: Role.guardian, same_day_only: true).size,
        '# of same day appointments from app + practice (total)' => appointments_booked(same_day_only: true).size
      },
      'Message Engagement' => {
        '# of guardians that sent a message' => guardians_who_sent_messages.size
      },
      'Response Time Metric' => {
        'Average Time to Case Close (minutes)' => average_case_time_in_minutes,
        'Median Time to Case Close (minutes)'=> median_case_time_in_minutes
      }
    }
  end

  # @return [Hash<String, #to_s>]
  def practice_engagement_single_value_stats
    @practice_engagement_value_stats ||= {
      '# of patients who had at least 1 appointment' => patients_with_appointments.size
    }
  end

  # @return [Hash<String, Hash<>>]
  def practice_engagement_monthly_stats
    @practice_engagement_monthly_stats ||= {
      '# of new patients enrolled in practice monthly' => new_patients_enrolled_monthly
    }
  end


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
