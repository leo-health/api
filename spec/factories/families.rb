FactoryGirl.define do
	factory :family do
		factory :family_with_members do 
			after(:create) do |instance|
				create(:user, :guardian, family: instance)
				create(:user, :guardian, family: instance)
				create(:patient, family: instance)
				create(:patient, family: instance)
				create(:patient, family: instance)
			end  
		end
	end
end
