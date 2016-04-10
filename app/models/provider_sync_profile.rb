class ProviderSyncProfile < ActiveRecord::Base
  belongs_to :provider, ->{ provider }, class_name: "User"
  belongs_to :sync_job, class_name: Delayed::Job
  validates :provider, presence: true

  after_commit :subscribe_to_athena, on: :create

  def subscribe_to_athena
    SyncProviderJob.new.subscribe_if_needed self, run_at: Time.now
  end
end
