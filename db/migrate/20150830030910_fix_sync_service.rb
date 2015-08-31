class FixSyncService < ActiveRecord::Migration
  def up
    drop_table :health_records

    add_column :patients, :athena_id, :integer, null: false, default: 0
    add_index :patients, :athena_id

    add_column :patients, :patient_updated_at, :datetime
    add_column :patients, :medications_updated_at, :datetime
    add_column :patients, :vaccines_updated_at, :datetime
    add_column :patients, :allergies_updated_at, :datetime
    add_column :patients, :vitals_updated_at, :datetime
    add_column :patients, :insurances_updated_at, :datetime
    add_column :patients, :photos_updated_at, :datetime

    add_column :provider_profiles, :athena_id, :integer, index: true, default: 0, null: false
    add_column :provider_profiles, :athena_department_id, :integer, default: 0, null: false

    remove_column :appointments, :status_id

    create_table :photos do |t|
      t.belongs_to :patient, index: true
      t.text :image, limit: 16.megabytes
      t.datetime :taken_at
      t.timestamps null: false
    end
  end

  def down
    create_table :health_records do |t|
      t.integer :athena_id, index: true, default: 0, null: false
      t.belongs_to :patient, index: true
      t.datetime :patient_updated_at
      t.datetime :medications_updated_at
      t.datetime :vaccines_updated_at
      t.datetime :allergies_updated_at
      t.datetime :vitals_updated_at
      t.datetime :insurances_updated_at
      t.datetime :photos_updated_at
      t.integer  :patient_id, null: false
      t.timestamps null: false
    end

    remove_column :patients, :athena_id
    remove_column :patients, :patient_updated_at
    remove_column :patients, :medications_updated_at
    remove_column :patients, :vaccines_updated_at
    remove_column :patients, :allergies_updated_at
    remove_column :patients, :vitals_updated_at
    remove_column :patients, :insurances_updated_at
    remove_column :patients, :photos_updated_at

    remove_column :provider_profiles, :athena_id
    remove_column :provider_profiles, :athena_department_id

    add_column :appointments, :status_id, :integer, null: false

    drop_table :photos
  end
end
