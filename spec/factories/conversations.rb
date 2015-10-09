FactoryGirl.define do
  factory :conversation do
    association :family, strategy: :build
    state :closed

    trait :open do
      after(:build) do |conversation|
        conversation.update_attributes(state: :open)
      end
    end

    trait :escalated do
      after(:build) do |conversation|
        conversation.update_attributes(state: :escalated)
      end
    end
  end
end
