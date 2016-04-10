class SyncProviderJob < PeriodicPollingJob

  attr_reader :provider_sync_profile

  def initialize(provider_sync_profile)
    super 1.hour
    @provider_sync_profile = provider_sync_profile
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    super **args.reverse_merge(priority: self.class::LOW_PRIORITY, owner: provider_sync_profile)
  end

  def subscribe(provider_sync_profile, **args)
    @provider_sync_profile = provider_sync_profile
    super **args.reverse_merge(priority: self.class::LOW_PRIORITY, owner: @provider_sync_profile)
  end

  def perform
    @service.sync_provider_leave @provider_sync_profile
  end

  def self.queue_name
    'get_provider_sync_profile'
  end
end
