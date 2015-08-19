class ChangePrioriyOnUserConversations < ActiveRecord::Migration
  def up
    remove_column :user_conversations, :priority
    add_column :user_conversations, :priority, :integer
  end

  def down
    add_column :user_conversations, :priority, :string
    remove_column :user_conversations, :priority
  end
end
