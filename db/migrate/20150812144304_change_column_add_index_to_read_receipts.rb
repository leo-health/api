class ChangeColumnAddIndexToReadReceipts < ActiveRecord::Migration
  def up
    rename_column :read_receipts, :participant_id, :reader_id
    add_index :read_receipts, ["message_id", "reader_id"], unique: true
  end

  def down
    remove_index :read_receipts, ["message_id", "reader_id"]
    rename_column :read_receipts, :reader_id, :participant_id
  end
end
