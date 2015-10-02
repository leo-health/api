class AddIsInviteToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :invited_user, :boolean, default: false
  end
end
