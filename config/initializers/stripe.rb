Stripe.api_key = ENV['STRIPE_API_KEY']
STRIPE_PLAN = "com.leohealth.standard"
STRIPE_PLAN_PARAMS_MOCK = {
                  :id => "com.leohealth.standard",
              :object => "plan",
              :amount => 2000,
             :created => 1464723959,
            :currency => "usd",
            :interval => "month",
      :interval_count => 1,
            :livemode => false,
                :name => "Leo Health - Standard",
:statement_descriptor => nil,
   :trial_period_days => nil
}
