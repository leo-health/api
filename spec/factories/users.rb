FactoryGirl.define do
  sequence :email do |n|
  "user#{n}@test.com"
  end

  factory :user do
    first_name 	{ ['Danish', 'Wuang', 'Zach', 'Ben', 'Nayan'].sample }
    last_name 	{ ['Munir', 'Kale', 'Freeman', 'Singh'].sample }
    dob 				{ 29.years.ago.to_s }
    gender					{ ['M', 'F'].sample }
    email
    password    'fake_pass'
    password_confirmation    'fake_pass'
    family_id    11
    association :family, factory: :family

    after(:create) do |u|
      u.family = Family.find_or_create_by(id: u.family_id)
    end

    trait :father do
      dob 				{ 48.years.ago.to_s }
      gender					'M'
      after(:create) { |u| u.add_role :parent }
    end

    trait :mother do
      dob 				{ 45.years.ago.to_s }
      gender					'F'
      after(:create) { |u| u.add_role :parent }
    end

    trait :child do
      dob 				{ 19.years.ago.to_s }
      gender 				'F'
      after(:create) { |u| u.add_role :child }
    end
  end
end
