FactoryGirl.define do
  factory :insurance_plan do
    plan_name 'PPO'
    athena_id 1
    association :insurer, strategy: :build
  end
end
