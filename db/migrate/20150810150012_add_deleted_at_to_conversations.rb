class AddDeletedAtToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :deleted_at, :datetime
  end
end
