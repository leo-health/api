FactoryGirl.define do
  factory :message do
    association :sender, factory: :user
    association :conversation, factory: :conversation
    body "MyText"
    type "MyString"
  end
end
