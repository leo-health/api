class CreateOnboardingGroups < ActiveRecord::Migration
  def change
    create_table :onboarding_groups do |t|
      t.string :group_name, null: false
      t.timestamps null: false
    end
  end
end
