FactoryGirl.define do
  factory :answer do
    association :user
    association :question
  end
end
