require 'rails_helper'

describe Conversation, type: :model do
	subject { FactoryGirl.create(:conversation_with_participants) }

	pending "add some examples to (or delete) #{__FILE__}, redo the relationship between conversation and paticipants"
end
