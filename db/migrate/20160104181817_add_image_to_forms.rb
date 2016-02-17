class AddImageToForms < ActiveRecord::Migration
  def change
    add_column :forms, :image, :string, null: false
  end
end
