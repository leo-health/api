class AddInsurancePlanIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :insurance_plan_id, :integer
  end
end
