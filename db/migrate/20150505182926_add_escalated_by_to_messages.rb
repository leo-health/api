class AddEscalatedByToMessages < ActiveRecord::Migration
  def change
   add_column :messages, :escalated_by_id, :integer, index: true
  end
end
