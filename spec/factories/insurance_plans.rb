FactoryGirl.define do
  factory :insurance_plan do
    plan_name 'PPO'
    association :insurer, strategy: :build
  end
end
