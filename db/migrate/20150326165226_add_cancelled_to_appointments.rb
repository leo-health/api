class AddCancelledToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :cancelled, :boolean, { null: false, default: false }
  end
end
