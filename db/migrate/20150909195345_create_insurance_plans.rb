class CreateInsurancePlans < ActiveRecord::Migration
  def change
    create_table :insurance_plans do |t|
      t.integer :insurer_id, null: false, index: true
      t.string :plan_name
      t.timestamps null: false
    end
  end
end
