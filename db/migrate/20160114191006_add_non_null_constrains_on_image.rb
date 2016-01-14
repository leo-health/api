class AddNonNullConstrainsOnImage < ActiveRecord::Migration
  def up
    remove_column :message_photos, :image
    add_column :message_photos, :image, :string, null: false
  end

  def down
    remove_column :message_photos, :image
    add_column :message_photos, :image, :string
  end
end
