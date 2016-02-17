class AddPracticeIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :practice_id, :integer, null: false
    add_index :appointments, :practice_id
  end
end
