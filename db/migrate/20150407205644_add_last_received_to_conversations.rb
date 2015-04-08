class AddLastReceivedToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :last_message_created, :datetime, index: true
  end
end
