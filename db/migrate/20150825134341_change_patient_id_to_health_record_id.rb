class ChangePatientIdToHealthRecordId < ActiveRecord::Migration
  def up
    remove_column :medications, :patient_id
    add_column :medications, :health_record_id, :integer, null: false
    add_index :medications, :health_record_id
    remove_column :vaccines, :patient_id
    add_column :vaccines, :health_record_id, :integer, null: false
    add_index :vaccines, :health_record_id
    remove_column :allergies, :patient_id
    add_column :allergies, :health_record_id, :integer, null: false
    add_index :allergies, :health_record_id
  end

  def down
    remove_column :medications, :health_record_id
    add_column :medications, :patient_id, :integer
    add_index :medications, :patient_id
    remove_column :vaccines, :health_record_id
    add_column :vaccines, :patient_id, :integer
    add_index :vaccines, :patient_id
    remove_column :allergies, :health_record_id
    add_column :allergies, :patient_id, :integer
    add_index :allergies, :patient_id
  end
end
