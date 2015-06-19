class BindInsuranceToPatient < ActiveRecord::Migration
  def change
    add_reference :insurances, :patient, index: true
    remove_reference :insurances, :user, index: true
  end
end
