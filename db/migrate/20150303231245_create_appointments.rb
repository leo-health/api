class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.string :appointment_status
      t.string :athena_appointment_type
      t.integer :leo_provider_id
      t.integer :athena_provider_id
      t.integer :leo_patient_id
      t.integer :athena_patient_id
      t.integer :booked_by_user_id
      t.integer :rescheduled_appointment_id
      t.integer :duration
      t.date :appointment_date
      t.column :appointment_start_time, 'time with zone'
      t.boolean :frozenyn
      t.string :leo_appointment_type
      t.integer :athena_appointment_type_id

      t.timestamps null: false
    end
  end
end
