class AddReadAndEscalatedFlagToUserConveration < ActiveRecord::Migration
  def change
    add_column :user_conversations, :read, :boolean, default: false, null: false
    add_column :user_conversations, :escalated, :boolean, default: false, null: false
  end
end
