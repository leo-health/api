class AddApnsPermissionToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :has_apns_permissions, :boolean
    add_column :sessions, :authenticated_at, :datetime
  end
end
