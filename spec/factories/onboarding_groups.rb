FactoryGirl.define do
  factory :onboarding_group do
    id    1
    group_name :invited_secondary_guardian
  end

  trait :generated_from_athena do
    group_name :generated_from_athena
  end
end
