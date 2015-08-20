FactoryGirl.define do
  factory :message do
    association :sender, factory: :user, strategy: :build
    association :conversation, strategy: :build
    body "MyText"
    message_type "MyString"
  end
end
