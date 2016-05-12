namespace :backfill do
  desc 'back fill provider_sync_profile on Appointment'
  task staff: :environment do
    StaffProfile.find_each do |staff|

      user = staff.staff
      staff.practice = user.practice
      if user.provider_sync_profile
        staff.provider_sync_profile = user.provider_sync_profile
        staff.athena_id = staff.provider_sync_profile.athena_id
      end

      Person.writable_column_names.map { |col| staff.send("#{col}=", user.send(col)) }

      begin
        staff.save!
        print "*"
      rescue e => Exception
        puts
        puts "Failed to save StaffProfile #{e}"
      end
    end
    puts
    puts "Finished filling Person attributes on StaffProfile"
  end
end
