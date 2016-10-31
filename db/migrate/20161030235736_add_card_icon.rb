class AddCardIcon < ActiveRecord::Migration
  def change
    create_table(:card_icons) do |t|
      t.string :icon, null: false
      t.string :card_type, null: false
    end
  end
end
