class CreateSyncTasks < ActiveRecord::Migration
  def change
    create_table :sync_tasks do |t|
      t.integer :sync_id, index: true, null: false, default: 0
      t.string :sync_type, index: true, null: false, default: ''

      t.timestamps null: false
    end
  end
end
