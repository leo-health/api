namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task appointments: :environment do
    Appointment.where(provider_sync_profile: nil).find_each do |appoitntment|
      if provider_sync_profile = appointment.provider.try(:provider_sync_profile)
        if appointment.update(provider_sync_profile: provider_sync_profile, booked_by: provider_sync_profile)
          print "*"
        else
          puts
          puts "Appointment #{appointment.id} update failed"
        end
      else
        puts
        puts "Provider #{appointment.provider} does not have a provider_sync_profile"
      end
    end
    puts
    puts "Finished filling provider_sync_profile for Appointment"
  end
end
