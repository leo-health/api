class SyncTask < ActiveRecord::Base
  #source of data for the sync
  enum sync_source: [ 
    :leo, 
    :athena
  ]

  # type of sync task
  #   gen_initial_appointment_tasks - generate appointment sync tasks for existing leo appointments
  #   appointment - sync appointment to/from athena
  enum sync_type: [
    :gen_initial_appointment_tasks,
    :appointment
  ]
end
