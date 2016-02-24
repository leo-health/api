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
    association :role, factory: [:role, :guardian]


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
