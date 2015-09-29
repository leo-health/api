FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    birth_date  { 29.years.ago }
    sex					{ ['M', 'F'].sample }
    email
    password    'password'
    association :family, factory: :family
    association :role, factory: [:role, :guardian]

    trait :guardian do
      sex					'M'
      association :role, factory: [:role, :guardian]
    end

    trait :super_user do
      family      nil
      association :role, factory: [:role, :super_user]
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
  end
end
