#don't delay jobs when running tests
Delayed::Worker.delay_jobs = !%w[ test ].include?(Rails.env)
