FactoryGirl.define do
  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    birth_date  { 29.years.ago }
    sex					{ ['M', 'F'].sample }
    email       {"user_#{rand(1000)}@test.com"}
    phone '1234567890'
    password     'password'
    password_confirmation 'password'
    family
    association :role, factory: [:role, :guardian]

    trait :guardian do
      sex					'M'
      association :role, factory: [:role, :guardian]
    end

    trait :financial do
      family      nil
      association :role, factory: [:role, :financial]
    end

    trait :clinical_support do
      family      nil
      association :role, factory: [:role, :clinical_support]
    end

    trait :customer_service do
      family      nil
      association :role, factory: [:role, :customer_service]
    end

    trait :clinical do
      family      nil
      association :role, factory: [:role, :clinical]
    end

    trait :bot do
      family      nil
      email       "leo_bot@leohealth.com"
      association :role, factory: [:role, :bot]
    end

    trait :operational do
      family      nil
      association :role, factory: [:role, :operational]
    end
  end
end
