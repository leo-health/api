namespace :application do

  desc 'Run all db operations and seed test data'
  task :init => :environment do
    begin
      ["db:drop", "db:create", "db:migrate", "db:seed", "db:test:prepare", "load:seed_staff", "load:seed_guardians"].each do |t|
        Rake::Task[t].reenable
        Rake::Task[t].invoke
      end
    end
  end
end

