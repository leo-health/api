class ReplaceProviderSyncProfileWithProvider < ActiveRecord::Migration
  def change
    rename_column :slots, :provider_sync_profile_id, :provider_id
    rename_column :staff_profiles, :provider_sync_profile_id, :provider_id
    rename_column :provider_sync_profiles, :provider_id, :user_id
    rename_table :provider_sync_profiles, :providers
  end
end
