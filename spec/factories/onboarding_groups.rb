FactoryGirl.define do
  factory :onboarding_group do
    group_name :primary_guardian

    trait :generated_from_athena do
      group_name :generated_from_athena
    end

    trait :invited_secondary_guardian do
      group_name :invited_secondary_guardian
    end
  end
end
