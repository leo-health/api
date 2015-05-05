# == Schema Information
#
# Table name: sync_tasks
#
#  id          :integer          not null, primary key
#  sync_id     :integer          default(0), not null
#  sync_source :integer          default(0), not null
#  sync_type   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

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
