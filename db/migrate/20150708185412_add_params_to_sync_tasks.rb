class AddParamsToSyncTasks < ActiveRecord::Migration
  def change
    add_column :sync_tasks, :sync_params, :string, null: false, default: ''
  end
end
