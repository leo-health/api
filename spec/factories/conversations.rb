FactoryGirl.define do
  factory :conversation do
    association :family, strategy: :build
    status :open
    trait :open do
      status :open
    end

    trait :escalated do
      status :escalated
    end

    trait :closed do
      status :closed
      last_closed_at Time.now
    end
  end
end
