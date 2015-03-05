class CreateConversationsParticipants < ActiveRecord::Migration
  def change
    create_table :conversations_participants, id: false do |t|
      t.references :conversation
      t.references :participant
      t.string :participant_role
    end
  end
end
