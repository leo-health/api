require 'rails_helper'

describe Conversation, type: :model do
	subject { FactoryGirl.create(:conversation_with_participants) }

	describe "conversation relationships" do	
		it "has 2 parent participants" do
			expect(subject.participants.count).to eq(2)
		end
	end
end
