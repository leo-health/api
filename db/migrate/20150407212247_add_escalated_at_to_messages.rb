class AddEscalatedAtToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :escalated_at, :datetime, index: true
  end
end
