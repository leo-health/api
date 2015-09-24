class CreateEscalationNotes < ActiveRecord::Migration
  def change
    create_table :escalation_notes do |t|
      t.integer :message_id, null: false
      t.integer :assignor_id, null: false
      t.integer :assignee_id, null: false
      t.string :priority_level, null: false
      t.string :note
      t.timestamps null: false
    end
    add_index :escalation_notes, :message_id
    add_index :escalation_notes, :assignor_id
    add_index :escalation_notes, :assignee_id
  end
end
