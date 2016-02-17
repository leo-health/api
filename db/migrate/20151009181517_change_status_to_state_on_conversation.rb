class ChangeStatusToStateOnConversation < ActiveRecord::Migration
  def up
    remove_column :conversations, :status, :string
    add_column :conversations, :state, :string, default: :closed
  end

  def down
    remove_column :conversations, :state, :string
    add_column :conversations, :status, :string, null: false
  end
end
