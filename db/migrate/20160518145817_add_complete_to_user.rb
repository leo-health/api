class AddCompleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :complete_status, :string
    # backfill: User.update_all(complete: true)
  end
end
