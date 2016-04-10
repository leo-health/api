class SyncProviderJob < PeriodicPollingJob

  attr_reader :provider_sync_profile

  def initialize
    super 20.minutes
    @service = AthenaProviderSyncService.new
  end

  def subscribe(provider_sync_profile, **args)
    @provider_sync_profile = provider_sync_profile
    super(**args.reverse_merge(priority: self.class::LOW_PRIORITY, owner: @provider_sync_profile))
  end

  def perform
    @service.sync_provider_leave @provider_sync_profile
  end

  def self.queue_name
    'get_provider_sync_profile'
  end
end
