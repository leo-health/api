require "sync_service_helper"
require "athena_health_api_helper"

class ProcessSyncTasksJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    SyncServiceHelper::Syncher.new(
      AthenaHealthApiHelper::AthenaHealthApiConnector.new()).process_all_sync_tasks()
  end
end
