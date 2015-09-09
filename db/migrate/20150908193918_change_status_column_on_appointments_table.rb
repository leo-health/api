class ChangeStatusColumnOnAppointmentsTable < ActiveRecord::Migration
  def up
    remove_column :appointments, :status
    remove_column :appointments, :status_id
    add_column :appointments, :appointment_status_id, :integer, null: false
    add_index :appointments, :appointment_status_id
  end

  def down
    add_column :appointments, :status, :string, null: false
    remove_column :appointments, :appointment_status_id
    add_column :appointments, :status_id, :integer, null: false
  end
end
