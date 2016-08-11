class AddDeletedAtToCardNotificationAndDeepLinkCard < ActiveRecord::Migration
  def change
    add_column :card_notifications, :deleted_at, :datetime
    add_column :deep_link_cards, :deleted_at, :datetime
  end
end
