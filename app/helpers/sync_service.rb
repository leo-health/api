class SyncService
  def self.start
    Delayed::Job.where(queue: [SyncProviderJob, SyncPracticeJob, SyncAppointmentsJob, SyncPatientJob].map(&:queue_name)).destroy_all
    [
      Provider,
      Practice,
      Patient.includes(:family)
    ].map { |model_class| model_class.find_each(&:subscribe_to_athena) }
  end
end
