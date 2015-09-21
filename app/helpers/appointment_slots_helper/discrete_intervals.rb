module AppointmentSlotsHelper
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
        res.intervals << coalesced unless coalesced.empty?
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
end
