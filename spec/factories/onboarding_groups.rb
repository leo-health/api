FactoryGirl.define do
  factory :onboarding_group do
    id    1
    group_name :invited_secondary_guardian
  end

  trait :generated_from_athena do
    group_name :generated_from_athena
  end

  trait :primary_guardian do
    group_name :primary_guardian
  end
end
