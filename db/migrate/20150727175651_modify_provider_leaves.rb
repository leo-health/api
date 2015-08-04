class ModifyProviderLeaves < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up {
        remove_column :provider_leaves, :start_time
        remove_column :provider_leaves, :end_time
        remove_column :provider_leaves, :date

        add_column :provider_leaves, :start_datetime, :datetime, null: false
        add_column :provider_leaves, :end_datetime, :datetime, null: false
      }

      dir.down {
        remove_column :provider_leaves, :start_datetime
        remove_column :provider_leaves, :end_datetime

        add_column :provider_leaves, :start_time, :time
        add_column :provider_leaves, :end_time, :time
        add_column :provider_leaves, :date, :date
      }
    end
  end
end
