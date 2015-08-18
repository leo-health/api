FactoryGirl.define do
  factory :user_conversation do
    association :staff, factory: [:user, :customer_service]
    association :conversation, factory: :conversation

    trait :financial do
      association :staff, factory: [:user, :clinical_support]
    end

    trait :clinical_support do
      association :staff, factory: [:user, :clinical_support]
    end

    trait :clinical do
      association :staff, factory: [:user, :clinical_support]
    end
  end
end
