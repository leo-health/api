class AddOnboardingGroupToSession < ActiveRecord::Migration
  def change
    add_reference :sessions, :onboarding_group
    add_index :sessions, :onboarding_group_id
  end
end
