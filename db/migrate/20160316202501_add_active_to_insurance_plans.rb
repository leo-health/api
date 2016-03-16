class AddActiveToInsurancePlans < ActiveRecord::Migration
  def change
    add_column :insurance_plans, :active, :boolean, default: true
  end
end
