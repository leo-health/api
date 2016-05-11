class AddMembershipStateToFamily < ActiveRecord::Migration
  def change
    add_column :families, :membership_type, :string
  end
end
