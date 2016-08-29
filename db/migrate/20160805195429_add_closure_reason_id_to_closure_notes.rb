class AddClosureReasonIdToClosureNotes < ActiveRecord::Migration
  def change
    add_column :closure_notes, :closure_reason_id, :integer, index: true
  end
  # backfill:closure_reason_id
end
