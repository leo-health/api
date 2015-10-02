class AddPriorityToUserConversations < ActiveRecord::Migration
  def change
    add_column :user_conversations, :priority, :string
  end
end
