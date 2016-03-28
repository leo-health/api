FactoryGirl.define do
  factory :role do
    name :guardian
    initialize_with { Role.find_or_create_by(name: name)}

    trait :financial do
      name  :financial
    end

    trait :clinical_support do
      name  :clinical_support
    end

    trait :customer_service do
      name  :customer_service
    end

    trait :guardian do
      name  :guardian
    end

    trait :clinical do
      name  :clinical
    end

    trait :patient do
      name  :patient
    end

    trait :bot do
      name  :bot
    end

    trait :operational do
      name  :operational
    end
  end
end
