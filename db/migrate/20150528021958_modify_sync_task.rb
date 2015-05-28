class ModifySyncTask < ActiveRecord::Migration
  def change
    remove_column :sync_tasks, :sync_source

    change_column :sync_tasks, :sync_type, :string, null: false, default: ''
  end
end
