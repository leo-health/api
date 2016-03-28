class AddNumFailedToSyncTask < ActiveRecord::Migration
  def change
    add_column :sync_tasks, :num_failed, :integer, null: false, default: 0
    add_column :sync_tasks, :working, :boolean, null: false, default: false
    add_index :sync_tasks, :num_failed
    add_index :sync_tasks, :working
  end
end
