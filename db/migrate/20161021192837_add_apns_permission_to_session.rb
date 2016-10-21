class AddApnsPermissionToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :apns_permissions, :boolean
    add_column :sessions, :authenticated_at, :datetime
  end
end
