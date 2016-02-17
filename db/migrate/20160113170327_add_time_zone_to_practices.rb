class AddTimeZoneToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :time_zone, :string
  end
end
