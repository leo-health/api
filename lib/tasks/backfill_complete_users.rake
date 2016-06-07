namespace :backfill do
  desc 'back fill user completion'
  task complete_users: :environment do
    User.find_each do |user|
      if user.save # Validation callback handles setting complete field
        print "*"
      else
        puts "\nFailed to save User"
      end
    end
    puts "\nFinished filling complete field on User"
  end
end
