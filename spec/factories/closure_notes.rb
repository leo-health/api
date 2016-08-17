FactoryGirl.define do
  factory :closure_note do
    conversation
    closure_reason_id 1
    association :closed_by, [:user, :customer_service]
    association :closure_reason, [:closure_reason]
  end
end
