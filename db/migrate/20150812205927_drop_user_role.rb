class DropUserRole < ActiveRecord::Migration
  def up
    drop_table :user_roles
    drop_table :users_roles
  end

  def down
    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end

    create_table :user_roles do |t|
      t.belongs_to :user, index: true
      t.belongs_to :role, index: true
      t.timestamps null: false
    end
  end
end
