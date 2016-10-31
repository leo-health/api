FactoryGirl.define do
  factory :user_survey do
    association :survey
    association :user
    association :patient
  end
end
