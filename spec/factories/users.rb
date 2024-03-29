require 'stripe_mock'

FactoryGirl.define do
  factory :user do
    first_name 	{ Faker::Name::first_name }
    last_name 	{ Faker::Name::first_name }
    birth_date  { 29.years.ago }
    sex					{ ['M', 'F'].sample }
    email       { Faker::Internet.email }
    phone '1234567890'
    password     'password'
    password_confirmation 'password'
    association :role, factory: [:role, :guardian]
    practice

    after(:create) do |instance, evaluator|
      instance.set_complete! unless evaluator.incomplete || evaluator.valid_incomplete
    end

    transient do
      incomplete false
      valid_incomplete false
    end

    trait :incomplete do
      first_name 	nil
      last_name 	nil
      incomplete true
    end

    trait :valid_incomplete do
      valid_incomplete true
    end

    trait :member do
      sex					'M'
      association :role, factory: [:role, :guardian]
      after(:create) do |instance|
        instance.family.update_or_create_stripe_subscription_if_needed! StripeMock.create_test_helper.generate_card_token
      end
    end

    trait :guardian do
      sex					'M'
      association :role, factory: [:role, :guardian]
    end

    trait :financial do
      practice
      association :role, factory: [:role, :financial]
    end

    trait :clinical_support do
      practice
      association :role, factory: [:role, :clinical_support]
    end

    trait :customer_service do
      practice
      association :role, factory: [:role, :customer_service]
    end

    trait :clinical do
      practice
      association :role, factory: [:role, :clinical]
      after(:build) do |user|
        user.provider ||= FactoryGirl.build(:provider, user: user)
      end
    end

    trait :bot do
      practice
      email       "leo_bot@leohealth.com"
      association :role, factory: [:role, :bot]
    end

    trait :operational do
      practice
      association :role, factory: [:role, :operational]
    end
  end
end
