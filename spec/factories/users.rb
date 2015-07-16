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
    password    'fake_pass'
    password_confirmation    'fake_pass'
    association :family, factory: :family

    trait :father do
      dob 				{ 48.years.ago.to_s }
      sex					'M'
      after(:create) { |u| u.add_role :guardian }
    end

    trait :mother do
      dob 				{ 45.years.ago.to_s }
      sex					'F'
      after(:create) { |u| u.add_role :guardian }
    end

    trait :child do
      dob 				{ 19.years.ago.to_s }
      sex 				'F'
      after(:create) { |u| u.add_role :patient }
    end
  end
end
