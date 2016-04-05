FactoryGirl.define do
  factory :user do
    first_name 	{ Faker::Name::first_name }
    last_name 	{ Faker::Name::first_name }
    birth_date  { 29.years.ago }
    vendor_id   { SecureRandom.urlsafe_base64(nil, false) }
    sex					{ ['M', 'F'].sample }
    email       { Faker::Internet.email }
    phone '1234567890'
    password     'password'
    password_confirmation 'password'
    association :role, factory: [:role, :guardian]
    practice

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
      after(:build) do |provider|
        provider.provider_sync_profile ||= FactoryGirl.build(:provider_sync_profile, provider: provider)
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
