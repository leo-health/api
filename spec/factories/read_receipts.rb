FactoryGirl.define do
  factory :read_receipt do
    association :reader, factory: :user
    association :message, factory: :message
  end
end
