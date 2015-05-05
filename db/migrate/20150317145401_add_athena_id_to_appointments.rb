class AddAthenaIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :athena_id, :integer, { null: false, default: 0 }
    add_index :appointments, :athena_id
  end
end
