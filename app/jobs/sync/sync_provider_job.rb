class SyncProviderJob < PeriodicPollingJob
  def initialize(provider_sync_profile)
    super interval: 1.hour, owner: provider_sync_profile, priority: LOW_PRIORITY
  end

  def perform
    AthenaProviderSyncService.new.sync_provider_leave @owner
  end

  def self.queue_name
    'get_provider_sync_profile'
  end
end
