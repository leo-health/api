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

  describe 'self.sort_conversations' do
    let!(:open_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_open_conversation){ create(:conversation, updated_at: 5.minutes.ago) }
    let!(:closed_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_closed_conversation){ create(:conversation, updated_at: 5.minutes.ago) }
    let!(:escalated_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_escalated_conversation){ create(:conversation, updated_at: 5.minutes.ago) }

    before do
      open_conversation.update_attributes(status: :open)
      latest_open_conversation.update_attributes(status: :open)
      escalated_conversation.update_attributes(status: :escalated)
      latest_escalated_conversation.update_attributes(status: :escalated)
    end

    it "should sort the conversations by status filed in oepn, escalated, closed order, and updated_at filed in descending order" do
      sorted_conversation = [latest_open_conversation, open_conversation, latest_escalated_conversation, escalated_conversation, latest_closed_conversation, closed_conversation]
      expect( Conversation.sort_conversations ).to eq( sorted_conversation )
    end
  end

  describe 'escalate_conversation' do
    let(:closed_conversation){ build(:conversation) }
    let(:customer_service){ create(:user, :customer_service) }
    let(:clinical){ create(:user, :clinical) }
    let(:note){ 'escalation note'}
    let(:priority){ 1 }

    it 'should respond to a instance of conversation class' do
      expect(closed_conversation).to respond_to(:escalate_conversation)
    end

    context 'escalate an already closed conversation' do
      it 'should not be able to escalate a closed conversation' do
        expect( closed_conversation.escalate_conversation(customer_service.id, clinical.id, note, priority) ).to eq(nil)
      end
    end

    context 'escalate an open conversation' do
      let(:open_conversation){ closed_conversation.update_attributes(status: :open) }

      it 'should create an escalation note'
    end

    context 'escalate an esclated conversation' do

    end
  end
end
