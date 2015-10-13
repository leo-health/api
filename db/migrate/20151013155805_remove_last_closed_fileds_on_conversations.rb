class RemoveLastClosedFiledsOnConversations < ActiveRecord::Migration
  def up
    remove_column :conversations, :last_closed_at
    remove_column :conversations, :last_closed_by_id
  end

  def down
    add_column :conversations, :last_closed_at, :datetime
    add_column :conversations, :last_closed_by_id, :integer
  end
end
