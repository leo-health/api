class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{ provider }, class_name: "User"
  belongs_to :sync_job, class_name: Delayed::Job
  validates :provider, presence: true

  def get_from_athena
    SyncServiceHelper::Syncer.instance.sync_provider_leave self
  end

  def subscribe_to_athena
    SyncProviderJob.subscribe_if_needed self
  end
end
