class AddAthenaIdToInsurancePlans < ActiveRecord::Migration
  def change
    #has to match athena insurancepackageid
    add_column :insurance_plans, :athena_id, :string, default: 0, null: false
  end
end
