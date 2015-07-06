# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_id   :integer
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :role do

    trait :super_user do
  		id    0
  		name  :super_user
  	end

    trait :financial do
      id    1
      name  :financial
    end

    trait :clinical_support do
      id    2
      name  :clinical_support
    end

    trait :customer_service do
      id    3
      name  :customer_service
    end

  	trait :guardian do
      id    4
      name  :guardian
    end

    trait :clinical do
      id    5
      name  :clinical
    end

    trait :patient do
      id    6
      name  :patient
    end

  end
end
