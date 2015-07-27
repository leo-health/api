class ModifyProviderAdditionalAvailabilities < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :provider_additional_availabilities, :start_time
        remove_column :provider_additional_availabilities, :end_time

        add_column :provider_additional_availabilities, :start_time, :string, null: false, default: '00:00'
        add_column :provider_additional_availabilities, :end_time, :string, null: false, default: '00:00'
      }

      dir.down {
        remove_column :provider_additional_availabilities, :start_time
        remove_column :provider_additional_availabilities, :end_time

        add_column :provider_additional_availabilities, :start_time, :time, null: true, default: nil
        add_column :provider_additional_availabilities, :end_time, :time, null: true, default: nil
      }
    end
  end
end
