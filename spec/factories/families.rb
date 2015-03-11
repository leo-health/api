# == Schema Information
#
# Table name: families
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :family do
		factory :family_with_members do 
			after(:create) do |instance|
				create(:user, :father, family: instance)
				create(:user, :mother, family: instance)
				create(:user, :first_child, family: instance)
				create(:user, :middle_child, family: instance)
				create(:user, :last_child, family: instance)
			end  
		end
	end
end