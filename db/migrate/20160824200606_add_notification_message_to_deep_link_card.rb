class AddNotificationMessageToDeepLinkCard < ActiveRecord::Migration
  def change
    add_column :deep_link_cards, :notification_message, :string
  end
end
