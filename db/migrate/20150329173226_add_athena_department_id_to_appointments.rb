class AddAthenaDepartmentIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :athena_department_id, :integer, default: 0, null: false
    add_index :appointments, :athena_department_id
  end
end
