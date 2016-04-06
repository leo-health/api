class AddDelayedJobPolymorphicOwner < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :owner_type, :string
    add_column :delayed_jobs, :owner_id, :integer
    add_index :delayed_jobs, [:owner_type, :owner_id]
  end

  def self.down
    remove_column :delayed_jobs, :owner_type
    remove_column :delayed_jobs, :owner_id
  end
end
