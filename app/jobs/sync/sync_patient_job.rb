class SyncPatientJob < PeriodicPollingJob

  attr_reader :patient

  def initialize
    super 20.minutes
    @service = AthenaPatientSyncService.new
  end

  def subscribe(patient, **args)
    @patient = patient
    super **args.reverse_merge(priority: self.class::MEDIUM_PRIORITY, owner: patient)
  end

  def perform
    [:vitals, :medications, :vaccines, :allergies].each do |s|
      @service.send "sync_#{s.to_s}".to_sym, @patient
    end
  end

  def self.queue_name
    'get_patient_health_record'
  end
end
