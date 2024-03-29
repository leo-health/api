namespace :backfill do
  desc 'back fill provider on Appointment'
  task appointments: :environment do
    Appointment.find_each do |appointment|
      provider_user = User.find_by_id(appointment.provider_id)
      booked_by_user = User.find_by_id(appointment.booked_by_id)
      if provider_user && booked_by_user
        booked_by = booked_by_user == provider_user ? provider_user.provider : booked_by_user
        if appointment.update(provider: provider_user.provider, booked_by: booked_by)
          print "*"
        else
          puts "\nAppointment #{appointment.id} update failed"
        end
      else
        puts "\nProvider #{appointment.provider} does not have a provider or a booked_by"
      end
    end
    puts "\nFinished filling provider and booked_by for Appointment"
  end
end
