
namespace :app do

  desc 'Run all db operations and seed test data'
  task init: :environment do
    ["db:reset", "app:seed"].each do |t|
      Rake::Task[t].invoke
      Rake::Task[t].reenable
      puts "#{t} completed".green
    end
  end

  desc 'Seed test data'
  task seed: :environment do
		Rake::Task["load:all"].execute
		puts "load:all completed".green
  end
end
