class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_id, null: false
      t.integer :choice_id, null: false
      t.text :text
      t.timestamps null: false
    end
    add_index :answers, [:user_id, :choice_id], unique: true
  end
end
