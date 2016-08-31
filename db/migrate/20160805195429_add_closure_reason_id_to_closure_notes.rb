class AddClosureReasonIdToClosureNotes < ActiveRecord::Migration
  def change
    add_column :closure_notes, :closure_reason_id, :integer, default: 6, index: true
  end
end
