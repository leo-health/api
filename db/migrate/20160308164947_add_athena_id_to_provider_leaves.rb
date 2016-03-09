class AddAthenaIdToProviderLeaves < ActiveRecord::Migration
  def change
    add_column :provider_leaves, :athena_id, :integer, null: false, default: 0
  end
end
