module AppointmentSlotsHelper
  class Interval
    include Comparable
    attr_accessor :start_val
    attr_accessor :end_val

    def initialize(start_val=0, end_val=0)
      @start_val = start_val
      @end_val = end_val
    end

    def <=>(other)
      if start_val != other.start_val || end_val != other.end_val
        if start_val < other.start_val
          return -1
        elsif start_val > other.start_val
          return 1
        else
          return end_val <=> other.end_val
        end
      else
        return 0
      end
    end

    def intersects?(other)
      start_val < other.end_val && other.start_val < end_val
    end

    def intersects_inclusive?(other)
      start_val <= other.end_val && other.start_val <= end_val
    end

    def +(other)
      return DiscreteIntervals.new([ self, other ]) if !intersects_inclusive?(other)
      return DiscreteIntervals.new([ Interval.new([start_val, other.start_val].min, [end_val, other.end_val].max) ])
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

      return DiscreteIntervals.new(res)
    end

    def intersect(other)
      res_int = Interval.new([start_val, other.start_val].max, [end_val, other.end_val].min)
      return res_int if !res_int.empty?
      return nil
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

        return res
      else
        coalesced = Interval.new(other.start_val, other.end_val)

        intersecting_inclusive(other).intervals.each { | interval | 
          coalesced.start_val = [ coalesced.start_val, interval.start_val ].min
          coalesced.end_val = [ coalesced.end_val, interval.end_val ].max
        }

        #this will compact all the fields
        res = self - coalesced
        res.intervals << coalesced if !coalesced.empty?
        return res
      end
    end

    def -(other)
      if other.kind_of?(DiscreteIntervals)
        res = self
        other.each { |interval| res = res - interval }

        return res
      else
        res = []

        intervals.each { |interval|
          tmp = interval - other
          res += tmp.intervals
        }

        return DiscreteIntervals.new(res)
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
        return res
      else
        res = []
        intervals.each { |interval| 
          int = interval.intersect(other)
          res << int if !int.nil?
        }

        return DiscreteIntervals.new(res)
      end
    end

    def intersecting(other)
      if other.kind_of?(DiscreteIntervals)
        res = DiscreteIntervals.new()
        other.intervals.each { |interval| res = res + intersecting(interval) }

        return res
      else
        res = []
        intervals.each { |interval| 
          res << interval if interval.intersects?(other)
        }

        return DiscreteIntervals.new(res)
      end
    end

    def intersecting_inclusive(other)
      if other.kind_of?(DiscreteIntervals)
        res = DiscreteIntervals.new()
        other.intervals.each { |interval| res = res + intersecting_inclusive(interval) }

        return res
      else
        res = []
        intervals.each { |interval| 
          res << interval if interval.intersects_inclusive?(other)
        }

        return DiscreteIntervals.new(res)
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

      return 0
    end
  end
end
