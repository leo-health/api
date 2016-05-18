class AddNonNullToAvatars < ActiveRecord::Migration
  def up
    remove_column :avatars, :avatar
    add_column :avatars, :avatar, :string
  end

  def down
    remove_column :avatars, :avatar
    add_column :avatars, :avatar, :string
  end
end
