class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.integer :athena_id, index: true, default: 0, null: false
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
