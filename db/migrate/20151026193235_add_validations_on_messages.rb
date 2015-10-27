class AddValidationsOnMessages < ActiveRecord::Migration
  def change
    change_column_null :messages, :sender_id, false
    change_column_null :messages, :conversation_id, false
    change_column_null :messages, :body, false
    change_column_null :messages, :type_name, false
    add_index :messages, :sender_id
    add_index :messages, :conversation_id
  end
end
