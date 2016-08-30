class RemoveDefaultValueOnClosureNotes < ActiveRecord::Migration
  def up
    change_column_default :closure_notes, :closure_reason_id, nil
  end

  def down
    change_column_default :closure_notes, :closure_reason_id, 6
  end
end
