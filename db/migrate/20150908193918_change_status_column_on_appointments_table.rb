class ChangeStatusColumnOnAppointmentsTable < ActiveRecord::Migration
  def up
    remove_column :appointments, :status
    add_column :appointments, :appointment_status_id, :integer, null: false
    add_index :appointments, :appointment_status_id
  end

  def down
    add_column :appointments, :status, :string
    remove_column :appointments, :appointment_status_id
  end
end
