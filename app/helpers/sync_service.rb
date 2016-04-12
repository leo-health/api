class SyncService
  def self.start
    [ProviderSyncProfile, Practice, Patient].each { |model_class|
      model_class.find_each(&:subscribe_to_athena)
    }
  end
end
