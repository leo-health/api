class ChangesOnSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :device_type, :string
    add_column :sessions, :device_identifier, :string
    add_column :sessions, :device_width, :string
    add_column :sessions, :device_height, :string
  end
end
