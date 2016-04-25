module Syncable
  extend ActiveSupport::Concern

  included do
    belongs_to :sync_status, dependent: :destroy
  end

  def has_synced?
    athena_id > 0
  end

  def should_attempt_sync?
    sync_status.should_attempt_sync
  end
end
