class SyncAppointmentsJob < PeriodicPollingJob
  def initialize(practice)
    super interval: 5.minutes, owner: practice, priority: self.class::HIGH_PRIORITY
  end

  def perform
    AthenaAppointmentSyncService.new.sync_appointments_for_practice @owner
  end

  def self.queue_name
    'get_appointments_for_practice'
  end
end
