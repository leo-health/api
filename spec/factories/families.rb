FactoryGirl.define do
	factory :family do
		factory :family_with_members do 
			after(:create) do |instance|
				create(:user, :father, family: instance)
				create(:user, :mother, family: instance)
				create(:user, :child, family: instance)
				create(:user, :child, family: instance)
				create(:user, :child, family: instance)
			end  
		end
	end
end
