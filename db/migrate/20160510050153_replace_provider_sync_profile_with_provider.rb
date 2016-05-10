class ReplaceProviderSyncProfileWithProvider < ActiveRecord::Migration
  def change
    remove_column :appointments, :provider_id, :integer
    rename_column :appointments, :provider_sync_profile_id, :provider_id
    rename_column :slots, :provider_sync_profile_id, :provider_id
    rename_column :staff_profiles, :provider_sync_profile_id, :provider_id
    rename_table :provider_sync_profiles, :providers
  end
end
