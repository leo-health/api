class AddDeepLinkCard < ActiveRecord::Migration
  def change
    create_table(:deep_link_cards) do |t|
      t.string :title
      t.string :body
      t.string :icon_url
      t.string :tint_color_hex
      t.string :tinted_header_text
      t.string :dismiss_button_text
      t.string :deep_link_button_text
      t.string :deep_link
      t.timestamps
    end

    create_table(:card_notifications) do |t|
      t.belongs_to :user
      t.references :card, polymorphic: true
      t.timestamps
    end
  end
end
