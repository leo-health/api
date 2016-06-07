class AddPersonToStaff < ActiveRecord::Migration
  def change
    add_column :staff_profiles, :athena_id, :integer
    add_column :staff_profiles, :title, :string
    add_column :staff_profiles, :first_name, :string
    add_column :staff_profiles, :middle_initial, :string
    add_column :staff_profiles, :last_name, :string
    add_column :staff_profiles, :suffix, :string
    add_column :staff_profiles, :sex, :string
    add_column :staff_profiles, :email, :string
    add_column :staff_profiles, :type, :string
    add_reference :staff_profiles, :avatar
  end
end
