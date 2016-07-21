class RemoveEnrollmentIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :enrollment_id
  end

  def down
    add_column :users, :enrollment_id, :integer
    add_index :users, :enrollment_id, unique: true
  end
end
