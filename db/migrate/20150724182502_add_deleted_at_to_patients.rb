class AddDeletedAtToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :deleted_at, :datetime
    add_index :patients, :deleted_at
  end
end
