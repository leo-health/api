class RemoveConversationParticipants < ActiveRecord::Migration
  def up
    drop_table :conversations_participants
  end

  def down
    create_table :conversations_participants, id: false do |t|
      t.references :conversation
      t.references :participant
      t.string :participant_role
    end
    add_index :conversations_participants, [:conversation_id, :participant_id], unique: true, name: 'conversations_participants_convid_pid'
    add_index :conversations_participants, [:participant_id, :conversation_id], unique: true, name: 'conversations_participants_pid_convid'
  end
end
