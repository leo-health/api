class AddEscalationFieldsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :escalated_to, :integer, index: true
    add_column :messages, :resolve_requested_at, :datetime, index: true
    add_column :messages, :resolved_approved_at, :datetime, index: true
  end
end
