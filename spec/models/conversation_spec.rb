# == Schema Information
#
# Table name: conversations
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  family_id            :integer
#  last_message_created :datetime
#  archived             :boolean
#  archived_at          :datetime
#  archived_by_id       :integer
#

require 'rails_helper'

describe Conversation, type: :model do
	subject { FactoryGirl.create(:conversation_with_participants) }

	describe "conversation relationships" do	
		it "has 2 parent participants" do
			expect(subject.participants.count).to eq(2)
		end
	end
end
