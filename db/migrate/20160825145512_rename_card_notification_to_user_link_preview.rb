class RenameCardNotificationToUserLinkPreview < ActiveRecord::Migration
  def change
    rename_table :card_notifications, :user_link_previews
  end
end
