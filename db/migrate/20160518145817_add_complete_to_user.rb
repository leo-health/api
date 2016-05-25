class AddCompleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :complete_status, :string
    # backfill:complete_users
  end
end
