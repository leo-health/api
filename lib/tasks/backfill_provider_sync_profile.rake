namespace :backfill do
  desc 'back fill provider on Appointment'
  task provider: :environment do
    Provider.find_each do |provider|
      Person.writable_column_names.map { |col| provider.send("#{col}=", provider.user.send(col)) }
      provider.credentials = provider.user.staff_profile.credentials
      if provider.save
        print "*"
      else
        puts
        puts "Failed to save Provider"
      end
    end
    puts
    puts "Finished filling Person attributes on Provider"
  end
end
