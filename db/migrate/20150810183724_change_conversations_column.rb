class ChangeConversationsColumn < ActiveRecord::Migration
  def up
    remove_column :conversations, :archive
    remove_column :conversations, :archived_at
    remove_column :conversations, :archived_by_id
    rename_column :conversations, :last_message_created, :last_message_created_at
    add_column :conversations, :state, :string, null: false
    add_column :conversations, :last_closed_at, :datetime
    add_column :conversations, :last_closed_by, :integer
  end

  def down
    add_column :conversations, :archive, :boolean
    add_column :conversations, :archived_at, :datetime
    add_column :conversations, :archived_by_id, :integer
    rename_column :conversations, :last_message_created_at, :last_message_created
    remove_column :conversations, :state
    remove_column :conversations, :last_closed_at
    remove_column :conversations, :last_closed_by
  end
end
