class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Leo Fields
      t.string :title,              null: true, default: ""
      t.string :first_name,         null: false, default: ""
      t.string :middle_initial,     null: true, default: ""
      t.string :last_name,          null: false, default: ""
      t.datetime :dob
      t.string :sex
      t.integer :role,              null: false
      t.integer :practice_id
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
