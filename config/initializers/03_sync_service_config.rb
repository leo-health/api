require 'sync_service_helper'

SyncService.configure do |config|
  #list of emails to notify when a sync task fails
  config.admin_emails = [ "sync@leohealth.com" ]

  #automatically schedule sync related tasks
  #should be true for every configuration other then test
  config.auto_gen_scan_tasks = !%w[ test ].include?(Rails.env)

  #sync service job will run at this interval
  config.job_interval = 1.minute

  #patient data will be synched at this interval
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.patient_data_interval = 15.minutes

  #appointment data will be synched at this interval
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.appointment_data_interval = 5.minutes

  #use delayed job logger for sync service
  config.logger = Delayed::Worker.logger
end
