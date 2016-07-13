every 1.day, :at => '0:00 am' do
  rake 'notification:complete_user_two_day_prior_appointment'
  rake 'notification:patient_birthday'
  rake 'notification:account_confirmation_reminder'
end

every 1.day, :at => '7:00am' do
  rake 'notification:escalated_conversation_email_digest'
end

every 1.day, :at => '12:00pm' do
  rake 'notification:escalated_conversation_email_digest'
end

every 1.minute do
  rake 'notification:complete_user_two_day_prior_appointment'
end
