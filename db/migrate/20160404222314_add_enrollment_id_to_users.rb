class AddEnrollmentIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enrollment_id, :integer
    add_index :users, :enrollment_id, unique: true
  end
end
