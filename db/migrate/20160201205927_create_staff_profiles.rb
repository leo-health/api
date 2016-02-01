class CreateStaffProfiles < ActiveRecord::Migration
  def change
    create_table :staff_profiles do |t|
      t.integer :staff_id, null: false
      t.string :specialties, array: true
      t.string :credentials, array: true
      t.timestamps null: false
    end
    add_index :staff_profiles, :staff_id, unique: true
  end
end
