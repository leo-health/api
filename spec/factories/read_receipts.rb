FactoryGirl.define do
  factory :read_receipt do
    association :reader, factory: :user
    message
  end
end
