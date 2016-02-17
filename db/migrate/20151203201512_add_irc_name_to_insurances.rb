class AddIrcNameToInsurances < ActiveRecord::Migration
  def change
    add_column :insurances, :irc_name, :string, null: false
  end
end
