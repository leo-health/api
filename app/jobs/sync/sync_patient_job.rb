class SyncPatientJob < PeriodicPollingJob
  def initialize(patient)
    super interval: 20.minutes, owner: patient, priority: self.class::MEDIUM_PRIORITY
  end

  def perform
    service = AthenaPatientSyncService.new
    [:vitals, :medications, :vaccines, :allergies].each do |s|
      service.send "sync_#{s.to_s}".to_sym, @owner
    end
  end

  def self.queue_name
    'get_patient_health_record'
  end
end
