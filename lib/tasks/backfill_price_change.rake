namespace :backfill do
  desc 'back fill price change on family'
  task vendor_id: :environment do
    Family.where.not(stripe_customer_id: nil).find_each{|f| f.update_stripe_plan(STRIPE_PLAN_HALF_PRICE)}
  end
end
