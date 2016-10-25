class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :body, null: false
      t.text :secondary
      t.integer :survey_id, index: true, null: false
      t.integer :order, null: false
      t.string :question_type, null: false
      t.string :media
      t.timestamps null: false
    end
  end
end
