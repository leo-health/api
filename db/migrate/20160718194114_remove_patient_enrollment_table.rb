class RemovePatientEnrollmentTable < ActiveRecord::Migration
  def up
    drop_table :patient_enrollments
  end

  def down
    create_table :patient_enrollments do |t|
      t.integer :guardian_enrollment_id, null: false
      t.string :email
      t.string :title
      t.string :first_name, null: false
      t.string :middle_initial
      t.string :last_name, null: false
      t.string :suffix
      t.datetime :birth_date, null: false
      t.string :sex, null: false
      t.timestamps null: false
      t.integer  :athena_id
    end
    add_index :patient_enrollments, :guardian_enrollment_id
  end
end
