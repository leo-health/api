class AddPersonAttributesToProvider < ActiveRecord::Migration
  def change
    add_column :provider_sync_profiles, :first_name, :string
    add_column :provider_sync_profiles, :last_name, :string
    add_column :provider_sync_profiles, :credentials, :string, array: true
    add_reference :provider_sync_profiles, :practice
    change_column_null :provider_sync_profiles, :provider_id, true
  end
end
