class AddLeaveUpdatedAtToProviderSyncProfile < ActiveRecord::Migration
  def change
    add_column :provider_sync_profiles, :leave_updated_at, :datetime
  end
end
