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
  	id     99
  	name   :guest

  	trait :admin do
  		id    1
  		name  :admin
  	end

  	trait :parent do
      id    21
      name  :parent
    end

    trait :child do
      id    22
      name  :child
    end

    trait :physician do
      id    11
      name  :physician
    end
  end
 end
