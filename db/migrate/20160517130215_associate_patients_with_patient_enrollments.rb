class AssociatePatientsWithPatientEnrollments < ActiveRecord::Migration
  def change
    add_reference :patients, :patient_enrollment
  end
end
