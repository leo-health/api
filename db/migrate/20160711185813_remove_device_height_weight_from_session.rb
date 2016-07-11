class RemoveDeviceHeightWeightFromSession < ActiveRecord::Migration
  def up
    remove_column :sessions, :device_height, :string
    remove_column :sessions, :device_width, :string
  end

  def down
    add_column :sessions, :device_height, :string
    add_column :sessions, :device_width, :string
  end
end
