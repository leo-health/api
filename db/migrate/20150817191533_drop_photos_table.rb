class DropPhotosTable < ActiveRecord::Migration
  def up
    drop_table :photos
  end

  def down
    create_table :photos do |t|
      t.belongs_to :patient, index: true
      t.text :image, limit: 16.megabytes
      t.datetime :taken_at
      t.timestamps null: false
    end
  end
end
