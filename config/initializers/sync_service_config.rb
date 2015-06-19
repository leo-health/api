require 'sync_service_helper'
require 'process_sync_tasks_job'

SyncService.configure do |config|
  config.auto_reschedule_job = !%w[ test ].include?(Rails.env)
  config.job_interval = 1.minutes
  config.auto_gen_scan_tasks = !%w[ test ].include?(Rails.env)
  config.patient_data_interval = 15.minutes
end

SyncService.start