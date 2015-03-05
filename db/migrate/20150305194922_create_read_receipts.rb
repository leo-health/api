class CreateReadReceipts < ActiveRecord::Migration
  def change
    create_table :read_receipts do |t|
      t.integer :message_id
      t.string :participant_id

      t.timestamps null: false
    end
  end
end
