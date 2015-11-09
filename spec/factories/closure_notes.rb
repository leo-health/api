FactoryGirl.define do
  factory :closure_note do
    conversation
    association :closed_by, factory: [:user, :customer_service]
  end
end
