class RemoveEscalationOnMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :escalated_at
    remove_column :messages, :escalated_by_id
    remove_column :messages, :escalated_to_id
    remove_column :user_conversations, :priority
  end

  def down
    add_column :messages, :escalated_at, :datetime
    add_column :messages, :escalated_by_id, :integer
    add_column :messages, :escalated_to_id, :integer
    add_column :user_conversations, :priority, :integer, default: 0
  end
end
