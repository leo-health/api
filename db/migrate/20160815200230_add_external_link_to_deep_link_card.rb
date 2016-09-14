class AddExternalLinkToDeepLinkCard < ActiveRecord::Migration
  def change
    add_column :deep_link_cards, :external_link, :string
  end
end
