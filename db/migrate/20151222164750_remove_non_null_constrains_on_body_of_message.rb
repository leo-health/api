class RemoveNonNullConstrainsOnBodyOfMessage < ActiveRecord::Migration
  def change
    change_column :messages, :body, :string, null: true
  end
end
