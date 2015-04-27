require "sync_service_helper"
require "athena_health_api_helper"

class ProcessSyncTasksJob
  def perform(*args)
    SyncServiceHelper::Syncher.new(
      AthenaHealthApiHelper::AthenaHealthApiConnector.new()).process_all_sync_tasks()
  end

  #limit to one attempt.  We will reschedule the job no matter what.
  def max_attempts
    1
  end

  def after(job)
    #reschedule next run
    #ProcessSyncTasksJob.schedule!(1.minutes.from_now.utc)
  end

  def self.schedule(run_at = Time.now)
    ProcessSyncTasksJob.schedule!(run_at) unless ProcessSyncTasksJob.scheduled?
  end
  
  def self.schedule!(run_at = Time.now)
    Delayed::Job.enqueue ProcessSyncTasksJob.new, { :run_at => run_at.utc }
  end

  def self.scheduled?
    Delayed::Job.where("handler LIKE ?", "%ProcessSyncTasksJob%").count > 0
  end
end
