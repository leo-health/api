class AddAthenaIdToPatientEnrollments < ActiveRecord::Migration
  def change
    add_column :patient_enrollments, :athena_id, :integer
  end
end
