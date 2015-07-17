class CreateProviderLeaves < ActiveRecord::Migration
  def change
    create_table :provider_leaves do |t|

      t.integer :athena_provider_id, index: true, default: 0, null: false
      t.string :description

      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false

      t.timestamps null: false
    end
  end
end
