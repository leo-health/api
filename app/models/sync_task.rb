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

  enum sync_type: [
    :scan_appointments,

    #push/pull appointment info
    :appointment,

    #create sync tasks for Users with the role :child
    :scan_patients,

    #push patient info
    :patient,

    #push patient photo
    :patient_photo,

    #pull patient allergies info
    :patient_allergies,

    #pull patient medications
    :patient_medications,

    #pull patient vaccines
    :patient_vaccines,

    #pull patient vitals
    :patient_vitals,

    #pull patient insurance
    :patient_insurance,
  ]
end
