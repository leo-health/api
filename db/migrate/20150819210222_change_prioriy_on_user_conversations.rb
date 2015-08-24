class ChangePrioriyOnUserConversations < ActiveRecord::Migration
  def up
    remove_column :user_conversations, :priority
    add_column :user_conversations, :priority, :integer, default: 0
  end

  def down
    remove_column :user_conversations, :priority
    add_column :user_conversations, :priority, :string
  end
end
