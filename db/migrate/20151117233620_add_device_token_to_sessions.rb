class AddDeviceTokenToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :device_token, :string
  end
end
