class RemoveNullFalseFromAppointmentsPatientId < ActiveRecord::Migration
  def up
    change_column :appointments, :patient_id, :integer, null: true
  end

  def down
    change_column :appointments, :patient_id, :integer, null: false
  end
end
