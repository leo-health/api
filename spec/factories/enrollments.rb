FactoryGirl.define do
  factory :enrollment do
    email
    password 'password'
    association :role, factory: [:role, :guardian]
  end
end
