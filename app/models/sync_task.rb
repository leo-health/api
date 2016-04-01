class SyncTask < ActiveRecord::Base

  @@max_queue_position = SyncTask.maximum(:queue_position)
  def self.max_queue_position
    @@max_queue_position
  end

  def enqueue
    @@max_queue_position += 1
    update_attributes(queue_position: @@max_queue_position)
    if @@max_queue_position > 10000
      SyncTask.transaction do
        SyncTask.all.find_each.with_index do |sync_task, index|
          sync_task.update_attributes(queue_position: index)
        end
      end
    end
    self
  end

end
