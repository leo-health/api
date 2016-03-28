require 'sync_service_helper'

SyncService.configure do |config|
  #list of emails to notify when a sync task fails
  config.admin_emails = [ "sync@leohealth.com" ]

  #automatically schedule sync related tasks
  #should be true for every configuration other then test
  config.auto_gen_scan_tasks = !%w[ test ].include?(Rails.env)

  #the longest interval at which the Sync Task job can run
  config.max_job_interval = 1.minute

  #failed job interval.  This will be multiplied by the number of failures to get the desired job interval
  config.failed_job_interval = 5.seconds

  #patient data will be synched at this interval
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.patient_data_interval = 15.minutes

  #appointment data will be synched at this interval
  #this does not apply to first sync.  That one is performed as soon as new data is entered in Leo.
  config.appointment_data_interval = 5.minutes

  config.scan_appointments_interval = 1.minute
  config.scan_remote_appointments_interval = 5.minutes
  config.scan_patients_interval = 1.minute
  config.scan_providers_interval = 1.minute
  
  #use delayed job logger for sync service
  config.logger = Delayed::Worker.logger
end
