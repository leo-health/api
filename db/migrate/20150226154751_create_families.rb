class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|

      t.timestamps null: false
    end
  end
end
