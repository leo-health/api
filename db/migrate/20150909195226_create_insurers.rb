class CreateInsurers < ActiveRecord::Migration
  def change
    create_table :insurers do |t|
      t.string :insurer_name, null: false
      t.string :phone
      t.string :fax
      t.timestamps null: false
    end
  end
end
