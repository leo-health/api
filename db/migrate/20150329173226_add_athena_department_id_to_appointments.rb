class AddAthenaDepartmentIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :athena_department_id, :integer
    add_index :appointments, :athena_department_id

    change_column_default(:appointments, :athena_department_id, 0)
    change_column_null(:appointments, :athena_department_id, false, default = 0)
  end
end
