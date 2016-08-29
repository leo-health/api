class AddCategoryToDeepLinkCard < ActiveRecord::Migration
  def change
    add_column :deep_link_cards, :category, :string
  end
end
