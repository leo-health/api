class AddOnboardingGroupToSession < ActiveRecord::Migration
  def change
    add_reference :sessions, :onboarding_group
  end
end
