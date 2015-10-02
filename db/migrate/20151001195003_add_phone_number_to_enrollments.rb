class AddPhoneNumberToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :phone_number, :string
  end
end
