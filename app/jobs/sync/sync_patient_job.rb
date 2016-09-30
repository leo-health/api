class SyncPatientJob < PeriodicPollingJob
  def initialize(patient)
    super interval: 20.minutes, owner: patient, priority: self.class::MEDIUM_PRIORITY
  end

  def perform
    AthenaHealthRecordSyncService.new.sync_health_record(@owner)
  end

  def self.queue_name
    'get_patient_health_record'
  end
end
