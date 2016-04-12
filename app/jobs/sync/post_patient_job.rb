class PostPatientJob < LeoDelayedJob
  attr_reader :patient

  def initialize(patient)
    @patient = patient
    @service = AthenaPatientSyncService.new
  end

  def start
    super(owner: @patient)
  end

  def perform
    @service.post_patient @patient
  end

  def self.queue_name
    'post_patient'
  end
end
