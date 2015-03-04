class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.string :appointment_status
      t.string :athena_appointment_type
      t.integer :leo_provider_id, index: true, null: false
      t.integer :athena_provider_id, index: true
      t.integer :leo_patient_id, index: true, null: false
      t.integer :athena_patient_id, index: true
      t.integer :booked_by_user_id, index: true, null: false
      t.integer :rescheduled_appointment_id, index: true
      t.integer :duration, null: false
      t.date :appointment_date, index: true, null: false
      t.column :appointment_start_time, 'time with zone', null: false
      t.boolean :frozenyn
      t.string :leo_appointment_type, index: true
      t.integer :athena_appointment_type_id, index: true
      t.integer :family_id, index: true, null: false

      t.timestamps null: false
    end
  end
end
