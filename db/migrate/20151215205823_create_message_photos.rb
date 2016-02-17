class CreateMessagePhotos < ActiveRecord::Migration
  def change
    create_table :message_photos do |t|
      t.string :image
      t.integer :message_id, index: true, null: false
      t.timestamps null: false
    end
  end
end
