env :PATH, '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
set :output, nil

every 1.day, :at => '12:01pm' do
  rake 'notification:complete_user_two_day_prior_appointment'
  rake 'notification:patient_birthday'
  rake 'notification:account_confirmation_reminder'
  rake 'notification:escalated_conversation_email_digest'
  rake 'notification:escalated_conversation_email_digest'
end

every 1.day, :at => '6:00am' do
  rake 'notification:practice_availability_change'
end
