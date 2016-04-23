class SyncService
  def self.seed(limit: nil)
    # TODO: Handle syncing of multiple athena Practices
    # Providers are associated with Practices in Leo, but do not have an associated Department in Athena
    # At the moment, we must assume a one to one relationship from Practice to Department
    SyncInitialPracticesJob.new(limit: 1).start
  end

  def self.start
    [ProviderSyncProfile, Practice, Patient].map { |model_class|
      model_class.find_each(&:subscribe_to_athena)
    }
  end
end
