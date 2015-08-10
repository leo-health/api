FactoryGirl.define do
  factory :conversation do
    association :family
    state :open
    trait :open do
      state :open
    end

    trait :escalated do
      state :escalated
    end

    trait :closed do
      state :closed
      last_closed_at Time.now
    end
  end
end
