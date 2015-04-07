# == Schema Information
#
# Table name: conversations
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  family_id  :integer
#

FactoryGirl.define do
  factory :conversation do
    factory :conversation_with_participants do 
    	after(:create) do |instance|
    		family = create(:family_with_members)
    		instance.participants << family.parents
    		instance.children << [family.children.first]
    	end
    end
  end
end
