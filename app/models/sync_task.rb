class SyncTask < ActiveRecord::Base

  def enqueue
    self.queue_position = SyncTask.maximum(:queue_position) + 1
    self
  end

end
