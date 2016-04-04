class AddVendorIdToEnrollmentAndUser < ActiveRecord::Migration
  def change
    add_column :users, :vendor_id, :string
    add_column :enrollments, :vendor_id, :string, null: false
    add_index :users, :vendor_id, unique: true
    add_index :enrollments, :vendor_id, unique: true
  end
end
