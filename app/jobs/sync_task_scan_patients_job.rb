require "sync_service_helper"
require "athena_health_api_helper"

class SyncTaskScanPatientsJob
  def perform(*args)
    SyncServiceHelper::Syncer.instance.process_scan_patients(SyncTask.new) if (Rails.env.develop? || Rails.env.production?)
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

  def self.schedule_if_needed(run_at = SyncService.configuration.scan_patients_interval.from_now.utc)
    Delayed::Job.enqueue SyncTaskScanPatientsJob.new, { run_at: run_at.utc } unless SyncTaskScanPatientsJob.scheduled?
  end
  
  def self.scheduled?
    Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%SyncTaskScanPatientsJob%").count > 0
  end
end
