class AddStripeCustomerIdToFamily < ActiveRecord::Migration
  def change
    add_column :families, :stripe_customer_id, :string
  end
end
