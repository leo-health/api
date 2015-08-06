class RemoveChildrenFromConversations < ActiveRecord::Migration
  def up
  	drop_table :conversations_children
  end

  def down
    create_table :conversations_children, id: false do |t|
      t.references :conversation
      t.references :child
    end
  end
end
