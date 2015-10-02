class RemoveColumnFromRoles < ActiveRecord::Migration
  def up
    remove_column :roles, :resource_id
    remove_column :roles, :resource_type
  end

  def down
    add_column :roles, :resource_id, :integer
    add_column :roles, :resource_type, :integer
  end
end
