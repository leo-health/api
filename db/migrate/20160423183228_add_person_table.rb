class AddPersonTable < ActiveRecord::Migration
  def change
    create_table(:people) do |t|
      t.string :title,              null: true, default: "" # what is the purpose of this default value?
      t.string :first_name,         null: false, default: ""
      t.string :middle_initial,     null: true, default: ""
      t.string :last_name,          null: false, default: ""
      t.datetime :dob
      t.string :sex
      t.integer :role,              null: false
      t.integer :practice_id
      t.string :email
      t.string :type
      t.belongs_to :avatar
      t.timestamps
    end
  end
end
