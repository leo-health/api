class SyncInitialPracticesJob < LeoDelayedJob
  def initialize(athena_practice_id: AthenaHealthApiHelper::AthenaHealthApiConnector.instance.connection.practiceid, limit: nil)
    @athena_practice_id = athena_practice_id
    @limit = limit
  end

  def perform
    service = AthenaPracticeSyncService.new
    service.sync_practices @athena_practice_id, limit: @limit
    service.sync_providers
  end

  def self.queue_name
    'get_practices'
  end
end
