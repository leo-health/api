class ChangeAppointments < ActiveRecord::Migration
  def up
    add_column :appointments, :status_id, :integer, null: false
    add_column :appointments, :status, :string, null: false
    add_column :appointments, :appointment_type_id, :integer, null: false
    add_column :appointments, :notes, :string
    add_column :appointments, :booked_by_id, :integer, null: false
    add_column :appointments, :provider_id, :integer, null: false
    add_column :appointments, :patient_id, :integer, null: false
    remove_column :appointments, :appointment_status
    remove_column :appointments, :athena_appointment_type
    remove_column :appointments, :leo_provider_id
    remove_column :appointments, :athena_provider_id
    remove_column :appointments, :leo_patient_id
    remove_column :appointments, :booked_by_user_id
    remove_column :appointments, :rescheduled_appointment_id
    remove_column :appointments, :frozenyn
    remove_column :appointments, :leo_appointment_type
    remove_column :appointments, :athena_appointment_type_id
    remove_column :appointments, :family_id
    remove_column :appointments, :athena_department_id
    add_index :appointments, :patient_id
    add_index :appointments, :provider_id
    add_index :appointments, :booked_by_id
    add_index :appointments, :appointment_type_id
  end

  def down
    remove_index :appointments, :patient_id
    remove_index :appointments, :provider_id
    remove_index :appointments, :booked_by_id
    remove_index :appointments, :appointment_type_id
    remove_column :appointments, :status_id
    remove_column :appointments, :status
    remove_column :appointments, :appointment_type_id
    remove_column :appointments, :notes
    remove_column :appointments, :booked_by_id
    remove_column :appointments, :provider_id
    remove_column :appointments, :patient_id
    add_column :appointments, :appointment_status, :string, null: false
    add_column :appointments, :athena_appointment_type, :string
    add_column :appointments, :leo_provider_id, :integer, null: false
    add_column :appointments, :athena_provider_id, :integer, null: false
    add_column :appointments, :leo_patient_id, :integer, null: false
    add_column :appointments, :booked_by_user_id, :integer, null: false
    add_column :appointments, :rescheduled_appointment_id, :integer
    add_column :appointments, :frozenyn, :boolean
    add_column :appointments, :leo_appointment_type, :string
    add_column :appointments, :athena_appointment_type_id, :integer, null: false
    add_column :appointments, :family_id, :integer, null: false
    add_column :appointments, :athena_department_id, :integer, default: 0, null: false
  end
end
