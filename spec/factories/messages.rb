FactoryGirl.define do
  factory :message do
    association :sender, factory: :user, strategy: :build
    association :conversation, strategy: :build
    body "MyText"
    type_name "text"
  end
end
