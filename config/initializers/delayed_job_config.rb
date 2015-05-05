#don't delete entries for failed jobs
Delayed::Worker.destroy_failed_jobs = true

#don't delay jobs when running tests
Delayed::Worker.delay_jobs = !%w[ test ].include?(Rails.env)

#make sure that the sync job is scheduled.  It will reschedule automatically.
ProcessSyncTasksJob.schedule #TODO: This line breaks the initializer if the delayed_jobs table isn't created