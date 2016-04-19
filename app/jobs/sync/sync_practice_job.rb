class SyncPracticeJob < PeriodicPollingJob
  def initialize(practice)
    super interval: 24.hours, owner: practice, priority: self.class::LOW_PRIORITY
  end

  def perform
    AthenaPracticeSyncService.new.sync_appointment_types @owner
    AthenaPracticeSyncService.new.sync_providers @owner
  end

  def success(job)
    super(job)
    SyncAppointmentsJob.new(@owner).subscribe_if_needed run_at: Time.now
  end

  def self.queue_name
    'get_providers'
  end
end
