class CreateClosureReasons < ActiveRecord::Migration
  def change
    create_table :closure_reasons do |t|
      t.integer :order
      t.boolean :has_note
      t.string :short_description
      t.string :long_description
    end
  end
end
