class ChangeResolvedToClosedOnMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :resolved_approved_at
    remove_column :messages, :resolved_requested_at
    add_column :messages, :last_closed_at, :datetime
  end

  def down
    remove_column :messages, :last_closed_at
    add_column :messages, :resolved_approved_at, :datetime
    add_column :messages, :resolved_requested_at, :datetime
  end
end
