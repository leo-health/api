namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task provider_sync_profile: :environment do
    ProviderSyncProfile.find_each do |provider_sync_profile|
      begin
        provider_sync_profile.update({
          first_name: provider_sync_profile.provider.first_name,
          last_name: provider_sync_profile.provider.last_name,
          credentials: provider_sync_profile.provider.staff_profile.credentials
        })
        print "*"
      rescue e => Exception
        puts
        puts "ProviderSyncProfile update failed"
      end
    end
  end
end
