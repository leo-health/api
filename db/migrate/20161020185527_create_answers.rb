class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_id, null: false
      t.integer :choice_id
      t.integer :question_id, null: false
      t.text :text
      t.timestamps null: false
    end
    add_index :answers, [:user_id, :question_id], unique: true
    add_index :answers, :question_id
    add_index :answers, :choice_id
  end
end
