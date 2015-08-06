class ModifyProviderAdditionalAvailabilities < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :provider_additional_availabilities, :start_time
        remove_column :provider_additional_availabilities, :end_time
        remove_column :provider_additional_availabilities, :date

        add_column :provider_additional_availabilities, :start_datetime, :datetime, null: false
        add_column :provider_additional_availabilities, :end_datetime, :datetime, null: false
      }

      dir.down {
        remove_column :provider_additional_availabilities, :start_datetime
        remove_column :provider_additional_availabilities, :end_datetime

        add_column :provider_additional_availabilities, :start_time, :time
        add_column :provider_additional_availabilities, :end_time, :time
        add_column :provider_additional_availabilities, :date, :date
      }
    end
  end
end
