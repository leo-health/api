class ChangeConversationClosedBy < ActiveRecord::Migration
  def up
    rename_column :conversations, :last_closed_by, :last_closed_by_id
    add_column :conversation_changes, :changed_by_id, :integer
  end

  def down
    rename_column :conversations, :last_closed_by_id, :last_closed_by
    remove_column :conversation_changes, :changed_by_id
  end
end
