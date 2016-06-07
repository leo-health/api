class AddPracticeIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :practice_id, :integer
    add_index :appointments, :practice_id
  end
end
