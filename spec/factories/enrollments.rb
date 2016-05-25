FactoryGirl.define do
  factory :enrollment do
    first_name 	{ Faker::Name::first_name }
    last_name 	{ Faker::Name::first_name }
    email { Faker::Internet.email }
    password 'password'
    phone { Faker::PhoneNumber.phone_number }
    vendor_id { SecureRandom.urlsafe_base64(nil, false) }
    association :role, factory: [:role, :guardian]
    practice
  end
end
