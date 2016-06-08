class AddClientVersionToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :client_version, :string
  end
end
