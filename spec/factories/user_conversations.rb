FactoryGirl.define do
  factory :user_conversation do
    association :participant, factory: :user
    association :conversation, factory: :conversation
  end
end
