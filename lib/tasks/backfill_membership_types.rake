namespace :backfill do
  desc 'back fill membership_type on Family'
  task membership_types: :environment do
    Family.find_each do |f|
      f.exempt_membership
      if f.save
        print "*"
      else
        puts "\nFailed to update member_type for family #{f.id}"
      end
    end
    puts "\nFinished!"
  end
end
