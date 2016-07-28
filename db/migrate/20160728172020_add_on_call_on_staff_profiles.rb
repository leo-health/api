class AddOnCallOnStaffProfiles < ActiveRecord::Migration
  def change
    add_column :staff_profiles, :on_call, :boolean, default: false
  end
end
