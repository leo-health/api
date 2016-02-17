class RenameCloseConversationsTable < ActiveRecord::Migration
  def up
    rename_table :close_conversation_notes, :closure_notes
  end

  def down
    rename_table :closure_notes, :close_conversation_notes
  end
end
