Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 2.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.sleep_delay = 30
Delayed::Worker.max_attempts = 2
