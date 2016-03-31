class AddQueuePositionToSyncTasks < ActiveRecord::Migration
  def change
    add_column :sync_tasks, :queue_position, :integer, default:0
    add_index :sync_tasks, :queue_position
  end
end
