class CreateAvatars < ActiveRecord::Migration
  def change
    create_table :avatars do |t|
      t.string :avatar, null: false
      t.references :owner, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
