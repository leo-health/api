class SyncProviderJob < SyncJob

  attr_reader :provider_sync_profile

  def initialize(provider_sync_profile)
    super 1.hour
    @provider_sync_profile = provider_sync_profile
  end

  # NOTE: Keyword arguments below are passed to Delayed::Job.enqueue
  def subscribe(**args)
    super **args.reverse_merge(priority: self.class::LOW_PRIORITY, owner: provider_sync_profile)
  end

  def self.subscribe(provider_sync_profile, **args)
    new(provider_sync_profile).subscribe **args
  end

  def self.subscribe_if_needed(provider_sync_profile, **args)
    new(provider_sync_profile).subscribe_if_needed provider_sync_profile, **args
  end

  def perform
    provider_sync_profile.get_from_athena
  end

  def self.queue_name
    'get_provider_sync_profile'
  end
end
