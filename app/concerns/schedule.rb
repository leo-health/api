module Schedule
  extend ActiveSupport::Concern

  class_methods do
    def time_to_datetime(date, time_str)
      Time.zone.parse(date.strftime("%Y-%m-%d") + " " + time_str).to_datetime
    end
  end

  def start_time_for_date(date)
    wday = date.strftime("%A").downcase
    self.class.time_to_datetime(date, send("#{wday}_start_time"))
  end

  def end_time_for_date(date)
    wday = date.strftime("%A").downcase
    self.class.time_to_datetime(date, send("#{wday}_end_time"))
  end
end
