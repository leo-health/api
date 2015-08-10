class ChangeMessageTypeToType < ActiveRecord::Migration
  def up
    remove_column :messages, :message_type
    add_column :messages, :type, :string, null: false
  end

  def down
    remove_column :messages, :type, :string, null: false
    add_column :messages, :message_type, :string
  end
end
