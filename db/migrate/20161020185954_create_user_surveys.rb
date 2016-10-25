class CreateUserSurveys < ActiveRecord::Migration
  def change
    create_table :user_surveys do |t|
      t.integer :user_id, null: false
      t.integer :patient_id
      t.integer :survey_id, null: false
      t.boolean :dismissed, default: false
      t.boolean :completed, default: false
      t.datetime :expiration_datetime
      t.timestamps null: false
    end

    add_index :user_surveys, [:survey_id, :user_id, :patient_id], unique: true
    add_index :user_surveys, :user_id
    add_index :user_surveys, :patient_id
  end
end
