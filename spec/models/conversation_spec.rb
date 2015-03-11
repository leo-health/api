# == Schema Information
#
# Table name: conversations
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Conversation, type: :model do
	subject { FactoryGirl.create(:conversation_with_participants) }
		# puts "\n\nConversation: #{subject.to_json}"
		# puts "Children: #{subject.children} #{subject.children.count}"
		# puts "Participants: #{subject.participants} #{subject.participants.count}"

	describe "conversation relationships" do	
		it "has 2 parent participants" do
			expect(subject.participants.count).to eq(2)
		end

		it "has one child" do
			expect(subject.children.count).to eq(1)
		end
	end
end
