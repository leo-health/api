FactoryGirl.define do
  factory :conversation do
    association :family, strategy: :build
    status :closed

    trait :open do
      after(:build) do |conversation|
        conversation.update_attributes(status: :open)
      end
    end

    trait :escalated do
      after(:build) do |conversation|
        conversation.update_attributes(status: :escalated)
      end
    end
  end
end
