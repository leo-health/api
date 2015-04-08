class AddArchivedToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :archived, :boolean, index: true
    add_column :conversations, :archived_at, :datetime, index: true
    add_column :conversations, :archived_by_id, :integer, index: true
  end
end
