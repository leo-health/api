class ChangeUserColumns < ActiveRecord::Migration
  def up
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :sign_in_count
    remove_column :users, :remember_created_at
    remove_column :users, :authentication_token
    remove_column :users, :sex
    add_column :users, :gender, :string, null: false
  end

  def down
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
    add_column :users, :sign_in_count, :integer, default: 0,  null: false
    add_column :users, :remember_created_at, :datetime
    add_column :users, :authentication_token, :string
    remove_column :users, :gender
    add_column :users, :sex, :string
  end
end
