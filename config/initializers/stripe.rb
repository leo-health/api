Stripe.api_key = ENV['STRIPE_API_KEY']
STRIPE_PLAN_HALF_PRICE = "com.leohealth.halfprice"
# STRIPE_PLAN = "com.leohealth.standard" # CURRENTLY NOT BEING USED
STRIPE_PLAN_PARAMS_MOCK = {
                  :id => STRIPE_PLAN_HALF_PRICE,
              :object => "plan",
              :amount => 1000,
             :created => 1464723959,
            :currency => "usd",
            :interval => "month",
      :interval_count => 1,
            :livemode => false,
                :name => "Leo Health - Standard",
:statement_descriptor => nil,
   :trial_period_days => nil
}
