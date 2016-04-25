namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task provider_sync_profile: :environment do
    Appointment.where(provider_sync_profile: nil).find_each do |appoitntment|
      provider_sync_profile = appointment.provider.try(:provider_sync_profile)
      if provider_sync_profile
        if appointment.update(provider_sync_profile: provider_sync_profile)
          print "*"
        else
          puts
          puts "Appointment.update failed"
        end
      else
        puts
        puts "Provider #{appointment.provider} does not have a provider_sync_profile"
      end
    end
  end
end
