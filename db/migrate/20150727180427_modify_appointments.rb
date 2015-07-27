class ModifyAppointments < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :appointments, :appointment_start_time

        add_column :appointments, :appointment_start_time, :string, null: false, default: '00:00'
      }

      dir.down {
        remove_column :appointments, :appointment_start_time

        add_column :appointments, :appointment_start_time, :time, null: true, default: nil
      }
    end
  end
end
