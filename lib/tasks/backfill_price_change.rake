namespace :backfill do
  desc 'back fill price change on family'
  task price_change: :environment do
    Family.where.not(stripe_customer_id: nil).find_each do |f|
      f.update_stripe_plan!(STRIPE_PLAN_HALF_PRICE)
      puts "successfully updated family #{f.id}"
    end
  end
end
