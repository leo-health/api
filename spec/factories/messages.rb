FactoryGirl.define do
  factory :message do
    association :sender, factory: :user
    association :conversation, factory: :conversation
    body "MyText"
    message_type "MyString"
  end
end
