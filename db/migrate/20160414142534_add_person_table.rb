class AddPersonTable < ActiveRecord::Migration
  def up
    create_table :person do |t|
      t.string :first_name
      t.string :last_name
    end
  end

  def down

  end
end
