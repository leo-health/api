class ChangesOnSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :device_type, :string
    add_column :sessions, :devise_identifier, :string
  end
end
