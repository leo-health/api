class CreateEscalationNotes < ActiveRecord::Migration
  def change
    create_table :escalation_notes do |t|
      t.integer :user_conversation_id, null: false
      t.integer :escalated_by_id, null: false
      t.integer :priority, null: false, default: 0
      t.string :note
      t.timestamps null: false
    end
    add_index :escalation_notes, :user_conversation_id
    add_index :escalation_notes, :escalated_by_id
  end
end
