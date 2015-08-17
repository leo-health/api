class CreatePractices < ActiveRecord::Migration
  def change
    create_table :practices do |t|
      t.string :name, null: false
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :fax
      t.string :phone
      t.string :email
      t.timestamps null: false
    end
  end
end
