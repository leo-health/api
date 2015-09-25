require 'rails_helper'

describe Conversation, type: :model do
	describe 'relations' do
		it{ is_expected.to have_many(:messages) }
		it{ is_expected.to have_many(:user_conversations) }
		it{ is_expected.to have_many(:staff).class_name('User').through(:user_conversations) }
    it{ is_expected.to have_many(:conversation_changes) }

    it{ is_expected.to belong_to(:last_closed_by).class_name('User') }
    it{ is_expected.to belong_to(:family) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:family) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
