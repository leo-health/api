class ModifyProviderSchedule < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :provider_schedules, :monday_start_time
        remove_column :provider_schedules, :monday_end_time
        remove_column :provider_schedules, :tuesday_start_time
        remove_column :provider_schedules, :tuesday_end_time
        remove_column :provider_schedules, :wednesday_start_time
        remove_column :provider_schedules, :wednesday_end_time
        remove_column :provider_schedules, :thursday_start_time
        remove_column :provider_schedules, :thursday_end_time
        remove_column :provider_schedules, :friday_start_time
        remove_column :provider_schedules, :friday_end_time
        remove_column :provider_schedules, :saturday_start_time
        remove_column :provider_schedules, :saturday_end_time
        remove_column :provider_schedules, :sunday_start_time
        remove_column :provider_schedules, :sunday_end_time

        add_column :provider_schedules, :monday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :monday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :tuesday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :tuesday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :wednesday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :wednesday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :thursday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :thursday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :friday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :friday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :saturday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :saturday_end_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :sunday_start_time, :string, null: false, default: '00:00'
        add_column :provider_schedules, :sunday_end_time, :string, null: false, default: '00:00'
      }

      dir.down {
        remove_column :provider_schedules, :monday_start_time
        remove_column :provider_schedules, :monday_end_time
        remove_column :provider_schedules, :tuesday_start_time
        remove_column :provider_schedules, :tuesday_end_time
        remove_column :provider_schedules, :wednesday_start_time
        remove_column :provider_schedules, :wednesday_end_time
        remove_column :provider_schedules, :thursday_start_time
        remove_column :provider_schedules, :thursday_end_time
        remove_column :provider_schedules, :friday_start_time
        remove_column :provider_schedules, :friday_end_time
        remove_column :provider_schedules, :saturday_start_time
        remove_column :provider_schedules, :saturday_end_time
        remove_column :provider_schedules, :sunday_start_time
        remove_column :provider_schedules, :sunday_end_time

        add_column :provider_schedules, :monday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :monday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :tuesday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :tuesday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :wednesday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :wednesday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :thursday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :thursday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :friday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :friday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :saturday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :saturday_end_time, :time, null: true, default: nil
        add_column :provider_schedules, :sunday_start_time, :time, null: true, default: nil
        add_column :provider_schedules, :sunday_end_time, :time, null: true, default: nil        
      }
    end
  end
end
