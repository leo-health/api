class RemoveResolvedFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :resolved_requested_at, :datetime
    remove_column :messages, :resolved_approved_at, :datetime
  end
end
