class AddSilentlyPublishedToUserLinkPreview < ActiveRecord::Migration
  def change
    add_column :user_link_previews, :sends_push_notification_on_publish, :boolean
  end
end
