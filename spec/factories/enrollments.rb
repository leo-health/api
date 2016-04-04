FactoryGirl.define do
  factory :enrollment do
    email  {"user_#{rand(1000)}@test.com"}
    password 'password'
    association :role, factory: [:role, :guardian]
  end
end
