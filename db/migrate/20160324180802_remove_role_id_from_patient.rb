class RemoveRoleIdFromPatient < ActiveRecord::Migration
  def up
    remove_column :patients, :role_id
  end

  def down
    add_column :patients, :role_id, :integer, null: false, default: 6
  end
end
