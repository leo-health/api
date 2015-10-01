class AddInsurancePlanIdToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :insurance_plan_id, :integer
  end
end
