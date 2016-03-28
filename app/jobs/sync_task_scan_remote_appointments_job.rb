require "sync_service_helper"
require "athena_health_api_helper"

class SyncTaskScanRemoteAppointmentsJob
  def perform(*args)
    Practice.find_each { |practice|
      SyncServiceHelper::Syncer.new.process_scan_remote_appointments(SyncTask.new(sync_id: practice.athena_id)) if (Rails.env.develop? || Rails.env.production?)
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
    SyncTaskScanRemoteAppointmentsJob.schedule_if_needed
  end

  def self.schedule_if_needed(run_at = SyncService.configuration.scan_remote_appointments_interval.from_now.utc)
    Delayed::Job.enqueue SyncTaskScanRemoteAppointmentsJob.new, { run_at: run_at.utc } unless SyncTaskScanRemoteAppointmentsJob.scheduled?
  end
  
  def self.scheduled?
    Delayed::Job.where("handler LIKE ? AND failed_at IS NULL", "%SyncTaskScanRemoteAppointmentsJob%").count > 0
  end
end
