class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.string :title
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.string :suffix
      t.string :sex
      t.integer :practice_id
      t.string :email
      t.string :encrypted_password
      t.integer :family_id
      t.string :stripe_customer_id
      t.integer :role_id
      t.datetime :deleted_at
      t.date :birth_date
      t.string :avatar_url
      t.integer :onboarding_group_id
      t.timestamps null: false
    end
  end
end
