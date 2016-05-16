class AddProviderToStaff < ActiveRecord::Migration
  def change
    add_reference :staff_profiles, :provider_sync_profile
    change_column :staff_profiles, :staff_id, :integer, null: true
    add_reference :staff_profiles, :practice
  end
end
