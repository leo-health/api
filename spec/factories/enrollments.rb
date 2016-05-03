FactoryGirl.define do
  factory :enrollment do
    email { Faker::Internet.email }
    password 'password'
    first_name 	{ Faker::Name::first_name }
    last_name 	{ Faker::Name::first_name }
    phone { Faker::PhoneNumber.phone_number }
    vendor_id { SecureRandom.urlsafe_base64(nil, false) }
    association :role, factory: [:role, :guardian]
  end
end
