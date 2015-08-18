class ChangeDatetimeOfDobOnInsurances < ActiveRecord::Migration
  def up
    remove_column :insurances, :holder_dob
    add_column :insurances, :holder_birth_date, :date
  end

  def down
    remove_column :insurances, :holder_birth_date
    add_column :insurances, :holder_dob, :datetime
  end
end
