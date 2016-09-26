module StartDateTimeBetween
  extend ActiveSupport::Concern

  # TODO: make this generic ANYFIELD_between(range_start, range_end)
  class_methods do
    def start_date_time_between(start_datetime, end_datetime)
      return unless start_datetime || end_datetime
      if !start_datetime
        where("start_datetime <= ?", end_datetime)
      elsif !end_datetime
        where("start_datetime >= ?", start_datetime)
      else
        where("start_datetime >= ? AND start_datetime <= ?", start_datetime, end_datetime)
      end
    end
  end
end
