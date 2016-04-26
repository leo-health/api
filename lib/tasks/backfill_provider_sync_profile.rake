namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task provider_sync_profile: :environment do
    ProviderSyncProfile.find_each do |provider_sync_profile|
      Person.writable_column_names.map { |col| provider_sync_profile.send("#{col}=", provider_sync_profile.provider.send(col)) }
      provider_sync_profile.credentials = provider_sync_profile.provider.staff_profile.credentials
      if provider_sync_profile.save
        print "*"
      else
        puts
        puts "Failed to save ProviderSyncProfile"
      end
    end
    puts
    puts "Finished filling Person attributes on ProviderSyncProfile"
  end
end
