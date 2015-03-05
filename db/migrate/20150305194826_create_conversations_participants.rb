class CreateConversationsParticipants < ActiveRecord::Migration
  def change
    create_table :conversations_participants do |t|
      t.references :conversation_id
      t.references :participant_id
      t.string :participant_role
    end
  end
end
