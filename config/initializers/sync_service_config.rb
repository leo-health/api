require 'sync_service_helper'
require 'process_sync_tasks_job'

SyncService.configure do |config|
  #automatically schedule sync related jobs and tasks
  #should be true for every configuration other then test
  config.auto_reschedule_job = !%w[ test ].include?(Rails.env)
  config.auto_gen_scan_tasks = !%w[ test ].include?(Rails.env)

  #sync service job will run at this interval
  config.job_interval = 1.minutes

  #patient data will be synched at this interval 
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.patient_data_interval = 15.minutes

  #appointment data will be synched at this interval
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.appointment_data_interval = 15.minutes

  #appointments will only be synched for the following department ids
  config.department_ids = [ 1, 2 ]
end

SyncService.start