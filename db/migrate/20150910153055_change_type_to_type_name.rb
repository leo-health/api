class ChangeTypeToTypeName < ActiveRecord::Migration
  def up
    rename_column :messages, :message_type, :type_name
  end

  def down
    rename_column :messages, :type_name, :message_type
  end
end
