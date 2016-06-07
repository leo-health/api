module Syncable
  extend ActiveSupport::Concern

  # Required methods
  # athena_id

  included do
    belongs_to :sync_status, dependent: :destroy
    alias_method_chain :sync_status, :auto_create
  end

  def has_synced?
    athena_id > 0
  end

  def sync_status_with_auto_create
    update(sync_status: SyncStatus.create!(owner: self)) unless sync_status_without_auto_create
    sync_status_without_auto_create
  end
end
