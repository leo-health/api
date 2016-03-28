require "sync_service_helper"
require "athena_health_api_helper"

class SyncTaskScanJob
  def perform(*args)
    Practice.find_each { |practice|
      SyncServiceHelper::Syncer.new.process_scan_remote_appointments(SyncTask.new(sync_id: practice.athena_id))
    }
  end

  #limit to one attempt.  We will reschedule the job manually if failed
  def max_attempts
    1
  end

  def queue_name
    'sync_service'
  end

  def after(job)
    #SyncTaskScanJob.schedule_if_needed
  end

  def self.schedule_if_needed()
    num_jobs = Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%SyncTaskJob%").count

    run_at = SyncService.configuration.appointment_data_interval.from_now.utc
    Delayed::Job.enqueue SyncTaskScanJob.new, { run_at: run_at.utc }
  end

end
