class AddAthenaUpdatedAtToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :sync_updated_at, :datetime
    remove_column :appointments, :athena_patient_id, :integer
  end
end
