namespace :app do
  desc 'Run all db operations and seed test data'
  task init: :environment do
    ["db:reset", "load:all"].each do |t|
      Rake::Task[t].invoke
      Rake::Task[t].reenable
      puts "#{t} completed".green
    end
  end
end
