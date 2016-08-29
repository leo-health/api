FactoryGirl.define do
  factory :closure_note do
    conversation
    closure_reason_id 1
    association :closed_by, factory: [:user, :customer_service]
    association :closure_reason, factory: [:closure_reason]
  end
end
