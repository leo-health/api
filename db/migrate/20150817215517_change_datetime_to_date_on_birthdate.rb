class ChangeDatetimeToDateOnBirthdate < ActiveRecord::Migration
  def up
    remove_column :users, :dob
    remove_column :patients, :birth_date
    add_column :users, :birth_date, :date
    add_column :patients, :birth_date, :date, null: false
  end

  def down
    remove_column :users, :birth_date
    remove_column :patients, :birth_date
    add_column :users, :dob, :datetime
    add_column :patients, :birth_date, :datetime, null: false
  end
end
