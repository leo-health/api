class AddClientVersionToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :client_version, :string
    add_column :sessions, :client_platform, :string
  end
end
