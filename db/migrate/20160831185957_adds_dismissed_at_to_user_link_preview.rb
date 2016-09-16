class AddsDismissedAtToUserLinkPreview < ActiveRecord::Migration
  def change
    add_column :user_link_previews, :dismissed_at, :datetime
  end
end
