class AddNotificationOnStaffProfiles < ActiveRecord::Migration
  def change
    add_column :staff_profiles, :sms_enabled, :boolean, default: false
  end
end
