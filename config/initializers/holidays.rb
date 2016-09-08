require 'holidays/core_extensions/date'
require "yaml"

class Date
  include Holidays::CoreExtensions::Date
end

Holidays.cache_between(Time.now, 2.years.from_now, :us, :observed)
