#don't delay jobs when running tests
Delayed::Worker.delay_jobs = !%w[ test ].include?(Rails.env)

#make sure that the sync job is scheduled.  It will reschedule automatically.
ProcessSyncTasksJob.schedule if Delayed::Job.table_exists? 