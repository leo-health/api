class CreateSyncTasks < ActiveRecord::Migration
  def change
    create_table :sync_tasks do |t|
      t.integer :sync_id, index: true, null: false, default: 0
      t.integer :sync_source, index: true, null: false, default: 0
      t.integer :sync_type, index: true, null: false

      t.timestamps null: false
    end
  end
end
