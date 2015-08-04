class ModifyAppointments < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :appointments, :appointment_start_time
        remove_column :appointments, :appointment_date

        add_column :appointments, :start_datetime, :datetime, null: false, default: "2015-01-01 00:00"
        change_column_default :appointments, :start_datetime, nil
        change_column_default :appointments, :appointment_status, nil

        add_index :appointments, :start_datetime
      }

      dir.down {
        remove_column :appointments, :start_datetime

        add_column :appointments, :appointment_start_time, :time
        add_column :appointments, :appointment_date, :date

        change_column_default :appointments, :appointment_status, "o"
      }
    end
  end
end
