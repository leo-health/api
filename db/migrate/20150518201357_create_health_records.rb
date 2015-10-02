class CreateHealthRecords < ActiveRecord::Migration
  def change
    create_table :health_records do |t|
      t.integer :athena_id, index: true, default: 0, null: false
      t.belongs_to :user, index: true

      t.datetime :patient_updated_at
      t.datetime :medications_updated_at
      t.datetime :vaccines_updated_at
      t.datetime :allergies_updated_at
      t.datetime :vitals_updated_at
      t.datetime :insurances_updated_at
      t.datetime :photos_updated_at

      t.timestamps null: false
    end
  end
end
