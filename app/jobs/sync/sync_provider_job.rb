class SyncProviderJob < SyncJob
  attr_accessor :provider_sync_profile
  def initialize(provider_sync_profile)
    super 20.minutes
    @provider_sync_profile = provider_sync_profile
  end

  def self.subscribe_if_needed(provider_sync_profile, **args)
    new(provider_sync_profile).subscribe_if_needed provider_sync_profile, **args
  end

  def self.subscribe(provider_sync_profile, **args)
    new(provider_sync_profile).subscribe **args
  end

  def subscribe(**args)
    super **args.reverse_merge(priority: 15, owner: provider_sync_profile)
  end

  def perform
    provider_sync_profile.get_from_athena
  end

  def self.queue_name
    'get_provider_sync_profile'
  end
end
