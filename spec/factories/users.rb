FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    dob 				{ 29.years.ago }
    sex					{ ['M', 'F'].sample }
    email
    password    'password'
    password_confirmation    'password'
    family_id    11
    association :family, factory: :family
    association :role, factory: :role

    trait :father do
      dob 				{ 48.years.ago }
      sex					'M'
      association :role, factory: [:role, :guardian]
    end

    trait :mother do
      dob 				{ 45.years.ago }
      sex					'F'
      association :role, factory: [:role, :guardian]
    end
  end
end
