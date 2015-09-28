class AddAuthenticationTokenToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :authentication_token, :string
    add_index :enrollments, :authentication_token
  end
end
