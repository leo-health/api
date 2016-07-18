class RemoveEnrollmentTable < ActiveRecord::Migration
  def up
    drop_table :enrollments
  end

  def down
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
      t.string :authentication_token
      t.boolean :invited_user, default: false
      t.integer :insurance_plan_id
      t.string :phone
      t.string :vendor_id, null: false
      t.timestamps null: false
    end
    add_index :enrollments, :authentication_token
    add_index :enrollments, :vendor_id, unique: true
  end
end
