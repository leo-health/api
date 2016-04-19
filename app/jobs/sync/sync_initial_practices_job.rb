class SyncInitialPracticesJob < LeoDelayedJob
  def initialize(athena_practice_id)
    @athena_practice_id = athena_practice_id
  end

  def perform
    AthenaPracticeSyncService.new.sync_practices @athena_practice_id
  end

  def success
    SyncService.start
  end

  def self.queue_name
    'get_practices'
  end
end
