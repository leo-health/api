class CreateEscalationNotes < ActiveRecord::Migration
  def change
    create_table :escalation_notes do |t|
      t.integer :conversation_id, null: false
      t.integer :escalated_to_id, null: false
      t.integer :escalated_by_id, null: false
      t.integer :priority, null: false, default: 0
      t.string :note
      t.timestamps null: false
    end
    add_index :escalation_notes, :conversation_id
    add_index :escalation_notes, :escalated_to_id
    add_index :escalation_notes, :escalated_by_id
  end
end
