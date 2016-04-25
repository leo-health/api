namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task provider_sync_profile: :environment do
    Appointment.where(provider_sync_profile: nil).find_each do |appoitntment|
      if provider_sync_profile = appointment.provider.try(:provider_sync_profile)
        begin
          appointment.update(provider_sync_profile: provider_sync_profile, booked_by: provider_sync_profile)
          provider_sync_profile.update({
            first_name: appointment.provider.first_name
            last_name: appointment.provider.last_name
            credentials: appointment.provider.staff_profile.credentials
          })
          print "*"
        rescue e => Exception
          puts
          puts "Appointment.update provider_sync_profile failed"
        end
      else
        puts
        puts "Provider #{appointment.provider} does not have a provider_sync_profile"
      end
    end
  end
end
