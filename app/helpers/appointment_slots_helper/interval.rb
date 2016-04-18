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

    def contains?(other)
      other.start_val >= start_val && other.end_val <= end_val
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
      return DiscreteIntervals.new([ Interval.new(start_val, end_val) ]) unless intersects?(other)

      res = []
      if other.start_val <= start_val
        res_int = Interval.new(other.end_val, end_val)
        res << res_int unless res_int.empty?
      else
        if other.end_val <= end_val
          res_int1 = Interval.new(start_val, other.start_val)
          res_int2 = Interval.new(other.end_val, end_val)
          res += [res_int1, res_int2]
        else
          res_int = Interval.new(start_val, other.start_val)
          res << res_int unless res_int.empty?
        end
      end

      DiscreteIntervals.new(res.reject { |res_interval| res_interval.empty? })
    end

    def intersect(other)
      res_int = Interval.new([start_val, other.start_val].max, [end_val, other.end_val].min)
      (res_int.empty?) ? nil : res_int
    end

    def empty?
      end_val <= start_val
    end
  end
end
