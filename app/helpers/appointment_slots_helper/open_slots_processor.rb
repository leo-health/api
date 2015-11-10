module AppointmentSlotsHelper
  class OpenSlotsProcessor
    def to_datetime_str(date, time)
      tm = Time.zone.parse(date.inspect + " " + time)
      DateTime.parse(tm.to_s).in_time_zone
    end

    def day_schedule_to_interval(schedule, date)
      date_name = date.strftime("%A").downcase
      start_time_method = "#{date_name}_start_time"
      end_time_method = "#{date_name}_end_time"
      if schedule.respond_to?(start_time_method) && schedule.respond_to?(end_time_method)
        start_time = schedule.public_send(start_time_method)
        end_time = schedule.public_send(end_time_method)
        Interval.new(to_datetime_str(date, start_time), to_datetime_str(date, end_time)) if (start_time && end_time)
      end
    end

    def get_provider_availability(athena_provider_id:, date:)
      start_datetime = to_datetime_str(date, "00:00")
      end_datetime = to_datetime_str(date, "23:59")

      availability = DiscreteIntervals.new

      #start with provider schedule
      schedule = ProviderSchedule.find_by!(athena_provider_id: athena_provider_id, active: true)

      schedule_int = day_schedule_to_interval(schedule, date)
      availability += schedule_int if schedule_int

      #add additional availability
      ProviderAdditionalAvailability.where("athena_provider_id = ? AND start_datetime >= ? AND start_datetime <= ?", athena_provider_id, start_datetime, end_datetime).find_each {
          |additional| availability += Interval.new(additional.start_datetime, additional.end_datetime)
      }

      #remove provider leaves
      ProviderLeave.where("athena_provider_id = ? AND start_datetime >= ? AND start_datetime <= ?", athena_provider_id, start_datetime, end_datetime).find_each {
          |leave| availability -= Interval.new(leave.start_datetime, leave.end_datetime)
      }

      #remove existing appointments
      booked_statuses = AppointmentStatus.where.not(status: 'x').collect(&:id)

      provider_profile = ProviderProfile.find_by!(athena_id: athena_provider_id)
      Appointment.where(provider_id: provider_profile.provider.id).where("start_datetime >= ? AND start_datetime <= ?", start_datetime, end_datetime).where(appointment_status_id: booked_statuses).find_each {
          |appt| availability -= Interval.new(appt.start_datetime, appt.duration.minutes.since(appt.start_datetime))
      }

      availability
    end

    def get_open_slots(athena_provider_id:, date:, durations:)
      availability = get_provider_availability(athena_provider_id: athena_provider_id, date: date)
      slots = []
      durations.each do |duration|
        availability.intervals.each do |interval|
          test_interval = Interval.new(interval.start_val, duration.minutes.since(interval.start_val))

          while interval.contains?(test_interval)
            slots << OpenSlot.new(test_interval.start_val, duration)
            test_interval = Interval.new(test_interval.end_val, duration.minutes.since(test_interval.end_val))
          end
        end
      end
      slots
    end
  end
end
