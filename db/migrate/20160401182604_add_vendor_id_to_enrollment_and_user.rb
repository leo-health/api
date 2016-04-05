class AddVendorIdToEnrollmentAndUser < ActiveRecord::Migration
  def up
    add_column :users, :vendor_id, :string
    add_column :enrollments, :vendor_id, :string
    add_index :users, :vendor_id, unique: true
    add_index :enrollments, :vendor_id, unique: true
  end

  def down
    remove_column :users, :vendor_id, :string
    remove_column :enrollments, :vendor_id, :string
  end
end
