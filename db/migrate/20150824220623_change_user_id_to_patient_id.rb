class ChangeUserIdToPatientId < ActiveRecord::Migration
  def up
    remove_column :health_records, :user_id
    add_column :health_records, :patient_id, :integer, null: false
    add_index :health_records, :patient_id, unique: true
  end

  def down
    remove_column :health_records, :patient_id
    add_column :health_records, :user_id, :integer
    add_index :health_records, :user_id
  end
end
