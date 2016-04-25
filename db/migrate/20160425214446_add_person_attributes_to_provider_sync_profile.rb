class AddPersonAttributesToProviderSyncProfile < ActiveRecord::Migration
  def change
    add_column :provider_sync_profiles, :title, :string
    add_column :provider_sync_profiles, :middle_initial, :string
    add_column :provider_sync_profiles, :suffix, :string
    add_column :provider_sync_profiles, :sex, :string
    add_column :provider_sync_profiles, :email, :string
  end
end
