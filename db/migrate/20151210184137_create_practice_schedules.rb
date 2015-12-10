class CreatePracticeSchedules < ActiveRecord::Migration
  def change
    create_table :practice_schedules do |t|
      t.integer :practice_id, index: true, null: false
      t.boolean :active, default: false
      t.string :schedule_type, null: false
      t.string :monday_start_time, null: false
      t.string :monday_end_time, null: false
      t.string :tuesday_start_time, null: false
      t.string :tuesday_end_time, null: false
      t.string :wednesday_start_time, null: false
      t.string :wednesday_end_time, null: false
      t.string :thursday_start_time, null: false
      t.string :thursday_end_time, null: false
      t.string :friday_start_time, null: false
      t.string :friday_end_time, null: false
      t.string :saturday_start_time, null: false
      t.string :saturday_end_time, null: false
      t.string :sunday_start_time, null: false
      t.string :sunday_end_time, null: false
      t.timestamps null: false
    end
  end
end
