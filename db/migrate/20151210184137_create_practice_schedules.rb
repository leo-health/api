class CreatePracticeSchedules < ActiveRecord::Migration
  def change
    create_table :practice_schedules do |t|
      t.integer :practice_id, index: true, null: false
      t.string :schedule_type, null: false
      t.time :monday_start_time, null: false
      t.time :monday_end_time, null: false
      t.time :tuesday_start_time, null: false
      t.time :tuesday_end_time, null: false
      t.time :wednesday_start_time, null: false
      t.time :wednesday_end_time, null: false
      t.time :thursday_start_time, null: false
      t.time :thursday_end_time, null: false
      t.time :friday_start_time, null: false
      t.time :friday_end_time, null: false
      t.time :saturday_start_time, null: false
      t.time :saturday_end_time, null: false
      t.time :sunday_start_time, null: false
      t.time :sunday_end_time, null: false
      t.timestamps null: false
    end
  end
end
