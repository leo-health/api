class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name, null: false
      t.string :survey_type, null: false
      t.string :display_name, null: false
      t.text :description
      t.text :prompt
      t.text :instructions
      t.string :media
      t.boolean :private, null: false, default: true
      t.boolean :required, null: false, default: true
      t.string :reason, null: false
      t.timestamps null: false
    end
  end
end
