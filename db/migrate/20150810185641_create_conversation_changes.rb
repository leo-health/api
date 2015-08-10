class CreateConversationChanges < ActiveRecord::Migration
  def change
    create_table :conversation_changes do |t|
      t.integer :conversation_id, null: false
      t.string :conversation_change
      t.timestamps null: false
    end
    add_index :conversation_changes, :conversation_id
  end
end
