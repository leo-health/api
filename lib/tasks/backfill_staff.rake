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

      staff.title = user.title
      staff.first_name = user.first_name
      staff.middle_initial = user.middle_initial
      staff.last_name = user.last_name
      staff.suffix = user.suffix
      staff.sex = user.sex
      staff.email = user.email
      staff.type = user.type
      staff.avatar = user.avatar

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
