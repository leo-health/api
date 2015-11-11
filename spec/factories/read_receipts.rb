FactoryGirl.define do
  factory :read_receipt do
    association :reader, factory: :user, strategy: :build
    message
  end
end
