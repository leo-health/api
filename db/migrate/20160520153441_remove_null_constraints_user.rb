class RemoveNullConstraintsUser < ActiveRecord::Migration
  def up
    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true
    change_column_null :users, :email, true
    change_column_null :users, :role_id, true
    remove_index :users, :email # remove unique constraint
    add_index :users, :email
  end

  def down
    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true
    change_column_null :users, :email, true
    change_column_null :users, :role_id, true
  end
end
