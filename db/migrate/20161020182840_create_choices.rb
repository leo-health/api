class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :media
      t.integer :question_id, index: true, null: false
      t.string :type, null: false, default: 'structured'
      t.integer :next_question_id
      t.timestamps null: false
    end
  end
end
