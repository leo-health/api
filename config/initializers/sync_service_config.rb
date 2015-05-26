require 'sync_service_helper'
require 'process_sync_tasks_job'

SyncService.configure do |config|
end

#make sure that the sync job is scheduled.  It will reschedule automatically.
if Delayed::Job.table_exists? && !%w[ test ].include?(Rails.env)
  ProcessSyncTasksJob.schedule
end
