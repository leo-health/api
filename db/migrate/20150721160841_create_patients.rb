class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :title
      t.string :first_name, null: false
      t.string :middle_initial
      t.string :last_name, null: false
      t.string :suffix
      t.datetime :birth_date, null: false
      t.string :sex, null: false
      t.integer :family_id, null: false
      t.string :email
      t.string :avatar_url
      t.string :role_id, null:false
    end
    add_index :patients, [:first_name, :family_id]
  end
end

