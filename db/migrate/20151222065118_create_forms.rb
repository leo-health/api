class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.references :patient,      index: true, null: false
      t.string :title,                         null: false
      t.text :notes
      t.references :submitted_by, index: true, null: false
      t.references :completed_by, index: true
      t.string :status

      t.timestamps                             null: false
    end
  end
end
