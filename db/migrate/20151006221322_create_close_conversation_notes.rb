class CreateCloseConversationNotes < ActiveRecord::Migration
  def change
    create_table :close_conversation_notes do |t|
      t.integer :conversation_id, null: false
      t.integer :closed_by_id, null: false
      t.string :note
      t.timestamps null: false
    end
  end
end
