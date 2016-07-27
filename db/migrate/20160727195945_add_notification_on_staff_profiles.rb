class AddNotificationOnStaffProfiles < ActiveRecord::Migration
  def change
    add_column :staff_profiles, :notification, :boolean, default: true
  end
end
