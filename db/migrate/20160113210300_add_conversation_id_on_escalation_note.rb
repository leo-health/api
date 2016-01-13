class AddConversationIdOnEscalationNote < ActiveRecord::Migration
  def change
    add_column :escalation_notes, :conversation_id, :integer, null: false
    add_index :escalation_notes, :conversation_id
  end
end
