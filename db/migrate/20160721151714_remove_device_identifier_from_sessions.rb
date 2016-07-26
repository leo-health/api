class RemoveDeviceIdentifierFromSessions < ActiveRecord::Migration
  def up
    remove_column :sessions, :device_identifier, :string
  end

  def down
    add_column :sessions, :device_identifier, :string
  end
end
