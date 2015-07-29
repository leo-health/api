class ChangeDefaultValueOnUsers < ActiveRecord::Migration
  def up
    change_column_default :users, :first_name, nil
    change_column_default :users, :last_name, nil
    change_column_default :users, :middle_initial, nil
    change_column_default :users, :title, nil
    change_column_default :users, :encrypted_password, nil
    change_column_default :users, :email, nil
  end

  def down
    change_column_default :users, :first_name, ''
    change_column_default :users, :last_name, ''
    change_column_default :users, :middle_initial, ''
    change_column_default :users, :title, ''
    change_column_default :users, :encrypted_password, ''
    change_column_default :users, :email, ''
  end
end
