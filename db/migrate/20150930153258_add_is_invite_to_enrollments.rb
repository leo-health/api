class AddIsInviteToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :is_invite, :boolean, default: false
  end
end
