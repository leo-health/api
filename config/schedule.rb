every 1.day, :at => '0:00 am' do
  rake 'appointment:five_day_notification'
  rake 'appointment:one_day_notification'
end
