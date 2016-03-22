class RemoveChildrenFromConversations < ActiveRecord::Migration
  def up
  	drop_table :conversations_children
  end

  def down
    create_table :conversations_children, id: false do |t|
      t.references :conversation
      t.references :child
    end
    add_index :conversations_children, [:conversation_id, :child_id], unique: true, name: 'conversations_participants_convid_cid'
    add_index :conversations_children, [:child_id, :conversation_id], unique: true, name: 'conversations_participants_cid_convid'
  end
end
