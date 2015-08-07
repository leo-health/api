FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    dob 				{ 29.years.ago.to_s }
    sex					{ ['M', 'F'].sample }
    email
    password    'password'
    password_confirmation    'password'
    association :family, factory: :family

    trait :father do
      title       "Mr"
      dob 				{ 48.years.ago.to_s }
      sex					'M'
      after(:create) { |u| u.add_role :guardian }
    end

    trait :mother do
      title       "Ms"
      dob 				{ 45.years.ago.to_s }
      sex					'F'
      after(:create) { |u| u.add_role :guardian }
    end

    trait :super_user do
      title       "Mr"
      dob 				{ 48.years.ago.to_s }
      sex					'M'
      family      nil
      after(:create) { |u| u.add_role :super_user }
    end

    trait :financial do
      title       "Mr"
      dob 				{ 48.years.ago.to_s }
      sex					'M'
      family      nil
      after(:create) { |u| u.add_role :financial }
    end

    trait :clinical_support do
      title       "Ms"
      dob 				{ 48.years.ago.to_s }
      sex					'F'
      family      nil
      after(:create) { |u| u.add_role :clinical_support }
    end

    trait :customer_service do
      title       "Ms"
      dob 				{ 48.years.ago.to_s }
      sex					'F'
      family      nil
      after(:create) { |u| u.add_role :customer_service }
    end

    trait :clinical do
      title       "Dr"
      dob 				{ 48.years.ago.to_s }
      sex					'F'
      family      nil
      after(:create) { |u| u.add_role :clinical }
    end
  end
end
