class ChangePhoneNumberToPhone < ActiveRecord::Migration
  def change
    rename_column :enrollments, :phone_number, :phone
    rename_column :users, :phone_number, :phone
  end
end
