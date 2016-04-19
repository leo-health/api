class SyncService
  def self.seed
    SyncInitialPracticesJob.new.start
  end

  def self.start
    [ProviderSyncProfile, Practice, Patient].each { |model_class|
      model_class.find_each(&:subscribe_to_athena)
    }
  end
end
