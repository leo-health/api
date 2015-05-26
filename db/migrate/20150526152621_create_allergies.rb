class CreateAllergies < ActiveRecord::Migration
  def change
    create_table :allergies do |t|
      t.belongs_to :patient, index: true

      t.integer :athena_id, index: true, default: 0, null: false

      #todo: add data

      t.timestamps null: false
    end
  end
end
