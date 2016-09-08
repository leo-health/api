class AddHolidaysToPractice < ActiveRecord::Migration
  def change
    add_column :practices, :holidays, :string, array: true, default: '{}'
    add_index  :practices, :holidays, using: 'gin'
  end
end
