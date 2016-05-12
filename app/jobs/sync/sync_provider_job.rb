class SyncProviderJob < PeriodicPollingJob
  def initialize(provider)
    super interval: 1.hour, owner: provider, priority: LOW_PRIORITY
  end

  def perform
    AthenaProviderSyncService.new.sync_open_slots @owner
  end

  def self.queue_name
    'get_provider'
  end
end
