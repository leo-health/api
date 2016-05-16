namespace :backfill do
  desc 'back fill person and provider on staff'
  task staff: :environment do
    StaffProfile.find_each do |staff|

      user = staff.staff
      staff.practice = user.practice
      if user.provider
        staff.provider = user.provider
        staff.athena_id = staff.provider.athena_id
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
