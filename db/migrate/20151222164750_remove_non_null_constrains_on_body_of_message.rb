class RemoveNonNullConstrainsOnBodyOfMessage < ActiveRecord::Migration
  def up
    change_column :messages, :body, :text, null: true
  end

  def down
    change_column :messages, :body, :text, null: false
  end
end
