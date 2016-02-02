require "sync_service_helper"
require "athena_health_api_helper"

class ProcessSyncTasksJob
  def perform(*args)
    SyncServiceHelper::Syncer.new().process_all_sync_tasks()
  end

  #limit to one attempt.  We will reschedule the job no matter what.
  def max_attempts
    1
  end

  def after(job)
    #reschedule next run
    if SyncService.configuration.auto_reschedule_job
      ProcessSyncTasksJob.schedule!(SyncService.configuration.job_interval.from_now.utc)
    end
  end

  def self.schedule(run_at = Time.now)
    ProcessSyncTasksJob.schedule!(run_at) unless ProcessSyncTasksJob.scheduled?
  end
  
  def self.schedule!(run_at = Time.now)
    Delayed::Job.enqueue ProcessSyncTasksJob.new, { run_at: run_at.utc }
  end

  def self.scheduled?
    Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%ProcessSyncTasksJob%").count > 0
  end
end
