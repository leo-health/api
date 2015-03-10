class AddIndexesToConversations < ActiveRecord::Migration
  def change
  	add_index :conversations_participants, [:conversation_id, :participant_id], unique: true, name: 'conversations_participants_convid_pid'
    add_index :conversations_participants, [:participant_id, :conversation_id], unique: true, name: 'conversations_participants_pid_convid'

    add_index :conversations_children, [:conversation_id, :child_id], unique: true, name: 'conversations_participants_convid_cid'
    add_index :conversations_children, [:child_id, :conversation_id], unique: true, name: 'conversations_participants_cid_convid'
  end
end
