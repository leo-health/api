class RemoveOnboardingGroupIdFromSessions < ActiveRecord::Migration
  def up
    remove_column :sessions, :onboarding_group_id, :integer
  end

  def down
    add_column :sessions, :onboarding_group_id, :integer
    add_index :sessions, :onboarding_group_id
  end
end
