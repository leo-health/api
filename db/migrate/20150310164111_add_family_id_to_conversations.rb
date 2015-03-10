class AddFamilyIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :family_id, :integer, index: true
  end
end
