class AddCompleteToUser < ActiveRecord::Migration
  def change
    add_column :users, :complete, :boolean, default: false
    # backfill: User.update_all(complete: true)
  end
end
