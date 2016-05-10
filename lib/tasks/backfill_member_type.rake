namespace :backfill do
  desc 'back fill member_type on user'
  task member_type: :environment do
    User.find_each do |u|
      u.member_type = MemberType.exempted
      if u.save
        print "*"
      else
        puts "\nFailed to update member_type for user #{u.id}"
      end
    end
    puts "\nFinished!"
  end
end
