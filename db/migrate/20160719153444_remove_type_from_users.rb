class RemoveTypeFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :type, :string
  end

  def down
    add_column :users, :type, :string
  end
end
