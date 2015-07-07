FactoryGirl.define do
  factory :conversation do
    factory :conversation_with_participants do 
    	after(:create) do |instance|
    		family = create(:family_with_members)
    		instance.participants << family.parents
    	end
    end
  end
end
