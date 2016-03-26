require "sync_service_helper"
require "athena_health_api_helper"

class SyncTaskJob
  def perform(*args)
    SyncServiceHelper::Syncer.new.process_one_task
  end

  #limit to one attempt.  We will reschedule the job manually if failed
  def max_attempts
    1
  end

  def queue_name
    'sync_service'
  end

  def after(job)
    SyncTaskJob.schedule_if_needed
  end

  def self.schedule_if_needed()
    min_jobs = SyncService.configuration.minimum_number_of_jobs

    num_jobs = Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%SyncTaskJob%").count
    return if num_jobs > min_jobs

    num_tasks = SyncTask.where(working: false, num_failed: 0).where.not("sync_type LIKE ?", "scan_%").count

    run_at = DateTime.now
    if (num_tasks == 0)
      run_at = SyncService.configuration.job_interval.from_now.utc
    end

    for i in num_jobs..min_jobs
      Delayed::Job.enqueue SyncTaskJob.new, { run_at: run_at.utc }
    end
  end

end
