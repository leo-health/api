FactoryGirl.define do
  factory :answer do
    association :user_survey
    association :question
  end
end
