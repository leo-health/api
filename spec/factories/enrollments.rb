FactoryGirl.define do
  factory :enrollment do
    email { Faker::Internet.email }
    password 'password'
    vendor_id { SecureRandom.urlsafe_base64(nil, false) }
    association :role, factory: [:role, :guardian]
  end
end
