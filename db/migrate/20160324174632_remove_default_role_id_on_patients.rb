class RemoveDefaultRoleIdOnPatients < ActiveRecord::Migration
  def up
    change_column_default :patients, :role_id, nil
  end

  def down
    change_column_default :patients, :role_id, 6
  end
end
