class PostPatientJob < LeoDelayedJob
  def initialize(patient)
    @patient = patient
  end

  def start
    super(owner: @patient)
  end

  def perform
    AthenaPatientSyncService.new.post_patient @patient
  end

  def self.queue_name
    'post_patient'
  end

  def failure(job)
    @patient.sync_status.update(should_attempt_sync: false)
  end
end
