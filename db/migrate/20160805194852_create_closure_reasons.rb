class CreateClosureReasons < ActiveRecord::Migration
  def change
    create_table :closure_reasons do |t|
      t.integer :reason_order
      t.boolean :user_input
      t.string :short_description
      t.string :long_description
    end
  end
end
