class CreateAppointmentTypes < ActiveRecord::Migration
  def change
    create_table :appointment_types do |t|
      t.integer :athena_id, index: true, default: 0, null: false
      t.string :description
      t.integer :duration, null: false
      t.timestamps null: false
    end
  end
end
