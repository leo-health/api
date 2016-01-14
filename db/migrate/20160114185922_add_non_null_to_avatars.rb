class AddNonNullToAvatars < ActiveRecord::Migration
  def change
    change_column :avatars, :avatar, :string, null: false
  end
end
