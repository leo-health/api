#don't delay jobs when running tests
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 30.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
