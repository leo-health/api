module AppointmentSlotsHelper
  class OpenSlot
    include Comparable

    attr_accessor :start_datetime
    attr_accessor :duration

    def initialize(start_datetime, duration)
      @start_datetime = start_datetime
      @duration = duration
    end

    def <=>(other)
      if start_datetime != other.start_datetime || duration != other.duration
        if start_datetime < other.start_datetime
          -1
        elsif start_datetime > other.start_datetime
          1
        else
          duration <=> other.duration
        end
      else
        0
      end
    end
  end
end
