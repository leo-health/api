module AppointmentSlotsHelper
  class Interval
    include Comparable
    attr_accessor :start_val
    attr_accessor :end_val

    def initialize(start_val, end_val)
      @start_val = start_val
      @end_val = end_val
    end

    def <=>(other)
      if start_val != other.start_val || end_val != other.end_val
        if start_val < other.start_val
          -1
        elsif start_val > other.start_val
          1
        else
          end_val <=> other.end_val
        end
      else
        0
      end
    end

    def intersects?(other)
      start_val < other.end_val && other.start_val < end_val
    end

    def intersects_inclusive?(other)
      start_val <= other.end_val && other.start_val <= end_val
    end

    def +(other)
      if !intersects_inclusive?(other)
        DiscreteIntervals.new([ self, other ])
      else 
        DiscreteIntervals.new([ Interval.new([start_val, other.start_val].min, [end_val, other.end_val].max) ])
      end
    end

    def -(other)
      return DiscreteIntervals.new([ Interval.new(start_val, end_val) ]) if !intersects?(other)

      res = []
      if other.start_val <= start_val
        res_int = Interval.new(other.end_val, end_val)
        res << res_int if !res_int.empty?
      else
        if other.end_val <= end_val
          res_int1 = Interval.new(start_val, other.start_val)
          res_int2 = Interval.new(other.end_val, end_val)
          return res_int1 + res_int2
        else
          res_int = Interval.new(start_val, other.start_val)
          res << res_int if !res_int.empty?
        end
      end

      DiscreteIntervals.new(res)
    end

    def intersect(other)
      res_int = Interval.new([start_val, other.start_val].max, [end_val, other.end_val].min)
      if !res_int.empty?
        res_int 
      else
        nil
      end
    end

    def empty?
      end_val <= start_val
    end
  end

  class DiscreteIntervals
    include Comparable
    attr_accessor :intervals

    def initialize(input=[])
      @intervals = input
    end

    def +(other)
      if other.kind_of?(DiscreteIntervals)
        res = self
        other.intervals.each { |interval| res = res + interval }

        res
      else
        coalesced = Interval.new(other.start_val, other.end_val)

        intersecting_inclusive(other).intervals.each { | interval | 
          coalesced.start_val = [ coalesced.start_val, interval.start_val ].min
          coalesced.end_val = [ coalesced.end_val, interval.end_val ].max
        }

        #this will compact all the fields
        res = self - coalesced
        res.intervals << coalesced if !coalesced.empty?

        res
      end
    end

    def -(other)
      if other.kind_of?(DiscreteIntervals)
        res = self
        other.each { |interval| res = res - interval }

        res
      else
        res = []

        intervals.each { |interval|
          tmp = interval - other
          res += tmp.intervals
        }

        DiscreteIntervals.new(res)
      end
    end

    def intersects?(other)
      if other.kind_of?(DiscreteIntervals)
        intervals.any? { |interval| other.intersects?(interval) }
      else
        intervals.any? { |interval| interval.intersects?(other) }
      end
    end

    def intersects_inclusive?(other)
      if other.kind_of?(DiscreteIntervals)
        intervals.any? { |interval| other.intersects_inclusive?(interval) }
      else
        intervals.any? { |interval| interval.intersects_inclusive?(other) }
      end
    end

    def intersect(other)
      if other.kind_of?(DiscreteIntervals)
        res = DiscreteIntervals.new()
        other.intervals.each { |interval| res = res + intersect(interval) }

        res
      else
        res = []
        intervals.each { |interval| 
          int = interval.intersect(other)
          res << int if !int.nil?
        }

        DiscreteIntervals.new(res)
      end
    end

    def intersecting(other)
      if other.kind_of?(DiscreteIntervals)
        res = DiscreteIntervals.new()
        other.intervals.each { |interval| res = res + intersecting(interval) }

        res
      else
        res = []
        intervals.each { |interval| 
          res << interval if interval.intersects?(other)
        }

        DiscreteIntervals.new(res)
      end
    end

    def intersecting_inclusive(other)
      if other.kind_of?(DiscreteIntervals)
        res = DiscreteIntervals.new()
        other.intervals.each { |interval| res = res + intersecting_inclusive(interval) }

        res
      else
        res = []
        intervals.each { |interval| 
          res << interval if interval.intersects_inclusive?(other)
        }

        DiscreteIntervals.new(res)
      end
    end

    def <=>(other)
      mine = intervals.sort { |x,y| x <=> y }
      theirs = other.intervals.sort { |x,y| x <=> y }

      if mine.length != theirs.length
        return mine.length <=> theirs.length
      end

      for i in 0..mine.length
        if mine[i] != theirs[i]
          return mine[i] <=> theirs[i]
        end
      end

      0
    end
  end

  module_function
  def to_date_time(date, time)
    tm = Time.zone.parse(date.inspect + " " + time.getlocal.hour.to_s + ":" + time.getlocal.min.to_s)
    DateTime.parse(tm.to_s).in_time_zone
  end

  module_function
  def to_date_time_str(date, time)
    tm = Time.zone.parse(date.inspect + " " + time)
    DateTime.parse(tm.to_s).in_time_zone
  end

  module_function
  def to_interval_str_duration(date, start_time, duration)
    Interval.new(to_date_time_str(date, start_time), duration.minutes.since(to_date_time_str(date, start_time)))
  end

  module_function
  def to_interval_str(date, start_time, end_time)
    Interval.new(to_date_time_str(date, start_time), to_date_time_str(date, end_time))
  end

  module_function
  def day_schedule_to_interval(schedule, date)
    if date.monday?
      start_time = schedule.monday_start_time
      end_time = schedule.monday_end_time
    elsif date.tuesday?
      start_time = schedule.tuesday_start_time
      end_time = schedule.tuesday_end_time
    elsif date.wednesday?
      start_time = schedule.wednesday_start_time
      end_time = schedule.wednesday_end_time
    elsif date.thursday?
      start_time = schedule.thursday_start_time
      end_time = schedule.thursday_end_time
    elsif date.friday?
      start_time = schedule.friday_start_time
      end_time = schedule.friday_end_time
    elsif date.saturday?
      start_time = schedule.saturday_start_time
      end_time = schedule.saturday_end_time
    else
      start_time = schedule.sunday_start_time
      end_time = schedule.sunday_end_time
    end

    if start_time.nil? || end_time.nil?
      nil 
    else
      to_interval_str(date, start_time, end_time)
    end
  end

  module_function
  def additional_availability_to_interval(availability)
    to_interval_str(availability.date, availability.start_time, availability.end_time)
  end
  
  module_function
  def leave_to_interval(leave)
    to_interval_str(leave.date, leave.start_time, leave.end_time)
  end

  module_function
  def appt_to_interval(appt)
    to_interval_str_duration(appt.appointment_date, appt.appointment_start_time, appt.duration)
  end

  module_function
  def get_provider_availability(athena_provider_id:, date:)
    availability = DiscreteIntervals.new

    #start with provider schedule
    schedule = ProviderSchedule.find_by!(athena_provider_id: athena_provider_id, active: true)
    Rails.logger.error("schedule: " + schedule.to_json);

    schedule_int = day_schedule_to_interval(schedule, date)
    Rails.logger.error("schedule_int: " + schedule_int.to_json);
    availability += schedule_int if !schedule_int.nil?
    Rails.logger.error("availability: " + availability.to_json);

    #add additional availability
    additional_availabilities = ProviderAdditionalAvailability.where(athena_provider_id: athena_provider_id, date: date).find_each {
      |additional| availability += additional_availability_to_interval(additional)
      Rails.logger.error("additional: " + additional.to_json);
    }
    Rails.logger.error("availability: " + availability.to_json);

    #remove provider leaves
    ProviderLeave.where(athena_provider_id: athena_provider_id, date: date).find_each { 
      |leave| availability -= leave_to_interval(leave)
      Rails.logger.error("leave: " + leave.to_json);
    }
    Rails.logger.error("availability: " + availability.to_json);

    #remove existing appointments
    Appointment.where(athena_provider_id: athena_provider_id, appointment_status: ["f", "2", "3", "4"], appointment_date: date).find_each {
      |appt| availability -= appt_to_interval(appt)
      Rails.logger.error("appt: " + appt.to_json);
    }
    Rails.logger.error("availability: " + availability.to_json);

    availability

  end
end
