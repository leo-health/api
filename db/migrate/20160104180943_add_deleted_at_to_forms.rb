class AddDeletedAtToForms < ActiveRecord::Migration
  def change
    add_column :forms, :deleted_at, :datetime
  end
end
