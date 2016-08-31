class ChangeClosureIdDefaults < ActiveRecord::Migration
  def up
    change_column_null :closure_notes, :closure_reason_id, false
  end

  def down
    change_column_null :closure_notes, :closure_reason_id, true
  end
end
