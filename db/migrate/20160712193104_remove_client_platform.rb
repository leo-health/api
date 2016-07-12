class RemoveClientPlatform < ActiveRecord::Migration
  def change
    remove_column :sessions, :client_platform, :string
  end
end
