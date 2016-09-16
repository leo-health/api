class ChangeCardReferenceToLinkPreview < ActiveRecord::Migration
  def change
    rename_column :user_link_previews, :card_type, :link_preview_type
    rename_column :user_link_previews, :card_id, :link_preview_id
  end
end
