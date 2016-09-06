Holidays.load_custom(Rails.root.join('config', 'custom_holidays.yaml'))
Holidays.cache_between(Time.now, 2.years.from_now, :us, :observed)
