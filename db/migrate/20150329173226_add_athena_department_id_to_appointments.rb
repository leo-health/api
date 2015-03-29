class AddAthenaDepartmentIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :athena_department_id, :integer, { null: false, default: 0 }
    add_index :appointments, :athena_department_id
  end
end
