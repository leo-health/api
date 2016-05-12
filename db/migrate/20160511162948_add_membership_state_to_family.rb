class AddMembershipStateToFamily < ActiveRecord::Migration
  def change
    add_column :families, :membership_type, :string
    add_index :families, :membership_type
  end
end
