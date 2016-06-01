class AddStripeCustomerModel < ActiveRecord::Migration
  def change
    add_column :families, :stripe_customer, :text
  end
end
