class RemoveEscalatedFromUserConversations < ActiveRecord::Migration
  def up
    remove_column :user_conversations, :escalated
  end

  def down
    add_column :user_conversations, :escalated, :boolean, null: false
  end
end
