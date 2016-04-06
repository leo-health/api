class SyncPatientJob < SyncJob
  attr_reader :patient
  def initialize(patient)
    super 10.minutes
    @patient = patient
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    super **args.reverse_merge(priority: self.class::MEDIUM_PRIORITY, owner: patient)
  end

  def self.subscribe(patient, **args)
    new(patient).subscribe **args
  end

  def self.subscribe_if_needed(patient, **args)
    new(patient).subscribe_if_needed patient, **args
  end

  def perform
    patient.instance_eval do
      [:vitals, :medications, :vaccines, :allergies].each do |s|
        public_send "get_#{s.to_s}_from_athena".to_sym
      end
    end
  end

  def self.queue_name
    'get_patient_health_record'
  end
end
