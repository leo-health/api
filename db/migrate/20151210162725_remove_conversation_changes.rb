class RemoveConversationChanges < ActiveRecord::Migration
  def up
    drop_table :conversation_changes
  end

  def down
    create_table :conversation_changes do |t|
      t.integer :conversation_id, null: false
      t.string :conversation_change
      t.timestamps null: false
    end
    add_index :conversation_changes, :conversation_id
  end
end
