class SyncInitialPracticesJob < LeoDelayedJob
  def initialize(athena_practice_id: AthenaHealthApiHelper::AthenaHealthApiConnector.instance.connection.practiceid, limit: nil)
    @athena_practice_id = athena_practice_id
    @limit = limit
  end

  def perform
    AthenaPracticeSyncService.new.sync_departments @athena_practice_id, limit: @limit
  end

  def self.queue_name
    'get_departments'
  end
end
