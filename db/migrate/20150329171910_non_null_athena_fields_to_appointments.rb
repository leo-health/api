class NonNullAthenaFieldsToAppointments < ActiveRecord::Migration
  def change
    change_column_default(:appointments, :athena_provider_id, 0)
    change_column_null(:appointments, :athena_provider_id, false, default = 0)

    change_column_default(:appointments, :athena_patient_id, 0)
    change_column_null(:appointments, :athena_patient_id, false, default = 0)

    change_column_default(:appointments, :appointment_status, "o")
    change_column_null(:appointments, :appointment_status, false, default = "o")

    change_column_default(:appointments, :athena_appointment_type_id, 0)
    change_column_null(:appointments, :athena_appointment_type_id, false, default = 0)
  end
end
