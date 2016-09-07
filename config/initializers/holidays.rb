require 'holidays/core_extensions/date'
require "yaml"

class Date
  include Holidays::CoreExtensions::Date
end

holidays = YAML.load_file(Rails.root.join('config', 'custom_holidays.yaml'))
holidays['months'].values.each do |month|
  month.each do |holiday|
    holiday['regions'] = Practice.all.map{ |p|p.name.gsub(/\s+/, '').underscore.to_sym }
  end
end
Holidays.load_custom(Rails.root.join('config', 'custom_holidays.yaml'))
params = Practice.all.map{ |p|p.name.gsub(/\s+/, '').underscore.to_sym }
params << :observed
Holidays.cache_between(Time.now, 2.years.from_now, *params)
