require "sync_service_helper"
require "athena_health_api_helper"

class SyncTaskJob
  def perform(*args)
    SyncServiceHelper::Syncer.instance.process_one_task
  end

  #limit to one attempt.  We will reschedule the job manually if failed
  def max_attempts
    1
  end

  def queue_name
    'sync_service'
  end

  def after(job)
    SyncService.start
  end

  def self.schedule_if_needed()
    min_jobs = SyncService.configuration.minimum_number_of_jobs

    num_jobs = Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%SyncTaskJob%").count
    return if num_jobs > min_jobs

    minimum_failed = SyncTask.minimum(:num_failed)
    minimum_failed ||= 0
    interval_to_use = [ (SyncService.configuration.failed_job_interval * minimum_failed).seconds, SyncService.configuration.max_job_interval].min
    run_at = interval_to_use.from_now.utc

    for i in num_jobs..min_jobs
      Delayed::Job.enqueue SyncTaskJob.new, { run_at: run_at.utc }
    end
  end

end
