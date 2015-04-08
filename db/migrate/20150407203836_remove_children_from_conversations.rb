class RemoveChildrenFromConversations < ActiveRecord::Migration
  def change
  	drop_table :conversations_children
  end
end
