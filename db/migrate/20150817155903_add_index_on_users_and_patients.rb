class AddIndexOnUsersAndPatients < ActiveRecord::Migration
  def change
    add_index :users, [:first_name, :last_name]
    add_index :patients, [:first_name, :last_name]
  end
end
