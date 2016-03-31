class SyncTask < ActiveRecord::Base

  before_create :enqueue

  @@max_queue_position = SyncTask.maximum(:queue_position) || 0
  def self.max_queue_position
    @@max_queue_position
  end

  def enqueue
    @@max_queue_position += 1
    self.queue_position = @@max_queue_position
    if @@max_queue_position > 10000
      if SyncTask.count < 10000
        SyncTask.transaction do
          SyncTask.all.find_each.with_index do |sync_task, index|
            sync_task.update_attributes(queue_position: index)
          end
          @@max_queue_position = SyncTask.maximum(:queue_position) || 0
        end
      end
    end
    self
  end

end
