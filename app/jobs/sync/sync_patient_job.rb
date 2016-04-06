class SyncPatientJob < SyncJob
  attr_accessor :patient
  def initialize(patient)
    super 10.minutes
    @patient = patient
  end

  def self.subscribe_if_needed(patient, **args)
    new(patient).subscribe_if_needed patient, **args
  end

  def self.subscribe(patient, **args)
    new(patient).subscribe **args
  end

  def subscribe(**args)
    super **args.reverse_merge(priority: 10, owner: patient)
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
