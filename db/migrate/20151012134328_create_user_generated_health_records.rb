class CreateUserGeneratedHealthRecords < ActiveRecord::Migration
  def change
    create_table :user_generated_health_records do |t|

      t.timestamps null: false
      t.datetime :deleted_at, index: true

      t.string :note, null: false
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :patient, index: true, foreign_key: true
    end
  end
end
