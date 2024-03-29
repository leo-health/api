namespace :backfill do
  desc 'back fill provider person attributes'
  task provider: :environment do
    Provider.find_each do |provider|
      Person.writable_column_names.map { |col| provider.send("#{col}=", provider.user.try(:send, col)) }
      provider.credentials = provider.user.try(:staff_profile).try(:credentials)
      if provider.save
        print "*"
      else
        puts "\nFailed to save Provider"
      end
    end
    puts "\nFinished filling Person attributes on Provider"
  end
end
