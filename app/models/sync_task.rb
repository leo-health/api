class SyncTask < ActiveRecord::Base
  #source of data for the sync
  enum source: [ :leo, :athena ]

  # type of sync task
  #   appointment - sync appointment to/from athena
  #   gen_initial_appointment_tasks - generate appointment sync tasks for existing leo appointments
  enum type: [ :appointment, :gen_initial_appointment_tasks ]
end
