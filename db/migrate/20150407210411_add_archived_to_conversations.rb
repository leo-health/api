class AddArchivedToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :archived, :boolean, index: true
    add_column :conversations, :archived_at, :datetime, index: true
    add_column :conversations, :archived_by, :integer, index: true
  end
end
