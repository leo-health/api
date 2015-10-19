class CreateHeightGrowthCurves < ActiveRecord::Migration
  def change
    create_table :height_growth_curves do |t|
      t.timestamps null: false

      t.integer :days, null: false, index: true
      t.string :sex, null: false, index: true
      t.float :l, null: false
      t.float :m, null: false
      t.float :s, null: false
    end
  end
end
