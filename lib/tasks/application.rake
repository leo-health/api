
namespace :app do

  desc 'Run all db operations and seed test data'
  task init: :environment do
    begin
      ["db:drop", "db:create", "db:migrate", "db:seed", "db:test:prepare", "app:seed"].each do |t|
        Rake::Task[t].invoke
        Rake::Task[t].reenable
        puts "#{t} completed".green
      end
    end
  end

  desc 'Seed test data'
  task seed: :environment do
  	begin
  		["load:seed_staff", "load:seed_guardians"].each do |t|
  			Rake::Task[t].execute
  			puts "#{t} completed".green
  		end
	end
  end
end
