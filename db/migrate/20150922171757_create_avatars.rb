class CreateAvatars < ActiveRecord::Migration
  def change
    create_table :avatars do |t|
      t.string :avatar
      t.references :owner, polymorphic: true, index: true, null: false
      t.timestamps null: false
    end
  end
end
