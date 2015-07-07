class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :user_id, :null => false
      t.string :authentication_token, :null => false
      t.datetime :deleted_at
      t.string :os_version
      t.string :platform
      t.timestamps null: false
    end

    add_index :sessions, :user_id, where: "deleted_at IS NULL"
    add_index :sessions, :authentication_token, where: "deleted_at IS NULL"
    add_index :sessions, :deleted_at
  end
end
