class SyncService
  def self.start
    [Provider, Practice, Patient].map { |model_class|
      model_class.find_each(&:subscribe_to_athena)
    }
  end
end
