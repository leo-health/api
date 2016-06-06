class AddProviderToStaff < ActiveRecord::Migration
  def change
    add_reference :staff_profiles, :provider_sync_profile
    change_column_null :staff_profiles, :staff_id, true
    add_reference :staff_profiles, :practice
  end

  def down
    change_column_null :staff_profiles, :staff_id, false
  end
end
