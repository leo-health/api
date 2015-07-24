#don't delay jobs when running tests
Delayed::Worker.delay_jobs = !%w[ test ].include?(Rails.env)
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 30.minutes
