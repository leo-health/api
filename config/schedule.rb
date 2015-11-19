every 1.day, :at => '0:00 am' do
  rake 'notification:five_day_prior_appoitment'
  rake 'notification:one_day_prior_appointment'
  rake 'notification:patient_birthday'
end
