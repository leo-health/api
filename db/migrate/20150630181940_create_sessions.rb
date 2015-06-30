class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :user_id, :null => false
      t.string :authentication_token, :null => false
      t.datetime :disabled_at
      t.string :os_version
      t.timestamps null: false
    end
    add_index :sessions, :user_id
    add_index :sessions, :authentication_token
  end
end
