class RemoveNullFalseFromAppointmentsPatientId < ActiveRecord::Migration
  def up
    change_column_null :appointments, :patient_id, true
  end

  def down
    change_column_null :appointments, :patient_id, true
  end
end
