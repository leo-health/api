FactoryGirl.define do
  factory :escalation_note do
    association :message, strategy: :build
    association :assignor, factory: [:user, :customer_service], strategy: :build
    association :assignee, factory: [:user, :clinical], strategy: :build
    priority_level "standard"
    note "message escalted to you"
  end
end
