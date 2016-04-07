class AddSoftDeleteToDelayedJob < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :deleted_at, :datetime
  end

  def self.down
    remove_column :delayed_jobs, :deleted_at
  end
end
