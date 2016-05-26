Stripe.api_key = ENV['STRIPE_API_KEY']
STRIPE_PLAN = "com.leohealth.standard-1_child"
StripePlanMap={
  0 => "com.leohealth.standard-no_child",
  1 => STRIPE_PLAN,
  2 => "com.leohealth.standard-2_children",
  3 => "com.leohealth.standard-3_children",
  4 => "com.leohealth.standard-4_children",
  5 => "com.leohealth.standard-5_or_more_children"
}
