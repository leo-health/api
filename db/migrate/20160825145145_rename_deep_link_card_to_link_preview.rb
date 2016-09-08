class RenameDeepLinkCardToLinkPreview < ActiveRecord::Migration
  def change
    rename_table :deep_link_cards, :link_previews
  end
end
