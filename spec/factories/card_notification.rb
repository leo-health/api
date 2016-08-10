FactoryGirl.define do
  factory :card_notification do
    association :user
    association :card, factory: [:deep_link_card]
  end
end
