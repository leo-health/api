class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.datetime :start_datetime, index: true
      t.datetime :end_datetime, index: true
      t.string :free_busy_type
      t.integer :athena_id
      t.belongs_to :provider_sync_profile
      t.belongs_to :appointment_type
      t.belongs_to :sync_status
      t.belongs_to :appointment
    end
  end
end
