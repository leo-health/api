class RemoveUserConversationIdAddEscalatedToIdOnEscalationNotes < ActiveRecord::Migration
  def up
    add_column :escalation_notes, :escalated_to_id, :integer, null: false
    remove_column :escalation_notes, :user_conversation_id
    add_index :escalation_notes, :escalated_to_id
  end

  def down
    remove_column :escalation_notes, :escalated_to_id
    add_column :escalation_notes, :user_conversation_id, :integer, null: false
  end
end
