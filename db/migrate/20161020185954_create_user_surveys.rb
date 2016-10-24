class CreateUserSurveys < ActiveRecord::Migration
  def change
    create_table :user_surveys do |t|
      t.integer :user_id, null: false
      t.integer :patient_id, null: false
      t.integer :survey_id, null: false
      t.boolean :dismissed, default: false
      t.boolean :completed, default: false
      t.timestamps null: false
    end

    add_index :user_surveys, [:patient_id, :survey_id], unique: true
    add_index :user_surveys, [:user_id, :survey_id], unique: true
    add_index :user_surveys, :survey_id
  end
end
