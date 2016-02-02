class AddAthenaIdToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :athena_id, :integer, default: 0, null: false
  end
end
