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
