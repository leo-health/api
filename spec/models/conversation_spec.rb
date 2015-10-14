require 'rails_helper'

describe Conversation, type: :model do
	describe 'relations' do
		it{ is_expected.to have_many(:messages) }
		it{ is_expected.to have_many(:user_conversations) }
		it{ is_expected.to have_many(:staff).class_name('User').through(:user_conversations) }
    it{ is_expected.to have_many(:conversation_changes) }
    it{ is_expected.to have_many(:closure_notes) }

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

  describe "state machines - conversations" do
    describe "before transition hook for escalate event" do
      it "should call #escalate_message_to_staff on a conversation instance" do

      end
    end

    describe "before transition hook for close event" do
      it "should call #close_conversation on a conversation instance" do

      end
    end

    describe "escalate" do
      let(:customer_service){ create(:user, :customer_service) }
      let(:clinical){ create(:user, :clinical) }
      let(:note){ 'escalation note'}
      let(:priority){ 1 }

      context "open conversation" do
        let(:open_conversation){ build(:conversation, :open) }
        let(:escalation_params){{ escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service }}

        it 'should create a user_conversation and a escalation_note record, then return true' do
          expect( UserConversation.count ).to eq(0)
          expect( EscalationNote.count ).to eq(0)
          expect( open_conversation.escalate(escalation_params) ).to eq(true)
          expect( UserConversation.count ).to eq(1)
          expect( EscalationNote.count ).to eq(1)
          expect( UserConversation.find_by( user_id: clinical.id, conversation_id: open_conversation.id).escalated ).to eq(true)
        end
      end

      context 'escalated conversation' do
        it "should escalate an esclated conversation to antoher staff" do

        end
      end

      context 'closed conversation' do
        it "should not escalate an closed conversation" do

        end
      end
    end

    describe "close" do
      it "should close an open conversation" do

      end

      it "should close an escalated conversation" do

      end

      it "should not close a closed conversation" do

      end
    end
  end

  describe '#escalate_conversation_to_staff' do
    let(:open_conversation){ build(:conversation, :open) }
    let(:customer_service){ create(:user, :customer_service) }
    let(:clinical){ create(:user, :clinical) }
    let(:note){ 'escalation note'}
    let(:priority){ 1 }
    let(:escalation_params){{ escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service }}

    context 'successfully escalate a non-closed conversation' do

      it 'should create a user_conversation and a escalation_note record, then return true' do
        expect( UserConversation.count ).to eq(0)
        expect( EscalationNote.count ).to eq(0)
        expect( open_conversation.escalate_conversation_to_staff(escalation_params) ).to eq(true)
        expect( UserConversation.count ).to eq(1)
        expect( EscalationNote.count ).to eq(1)
        expect( UserConversation.find_by( user_id: clinical.id, conversation_id: open_conversation.id).escalated ).to eq(true)
      end
    end

    context 'fail to create escalation note' do
      before do
        escalation_params.except!(:escalated_by)
      end

      it 'should rollback changes made before the error happens and return false' do
        expect( UserConversation.count ).to eq(0)
        expect( open_conversation.escalate_conversation_to_staff(escalation_params) ).to eq(false)
        expect( UserConversation.count ).to eq(0)
      end
    end
  end

  describe '#close_conversation' do
    let(:open_conversation){ build(:conversation, :open) }
    let(:note){ 'close the conversation'}
    let(:clinical){ create(:user, :clinical) }
    let(:customer_service){ create(:user, :customer_service) }
    let(:close_params){{closed_by: customer_service, note: note}}

    before do
      escalation_params = { escalated_to: clinical, note: note, escalated_by: customer_service }
      open_conversation.escalate_conversation_to_staff(escalation_params)
    end

    context 'successfully close a non closed conversation' do
      it 'should update the conversation status to closed' do
        expect(UserConversation.find_by(conversation: open_conversation, staff: clinical).escalated).to eq(true)
        expect(ClosureNote.count).to eq(0)
        expect(open_conversation.close_conversation( close_params)).to eq(true)
        expect(UserConversation.find_by(conversation: open_conversation, staff: clinical).escalated).to eq(false)
        expect(ClosureNote.count).to eq(1)
      end
    end

    context 'fail to close a conversation' do
      before do
        close_params.except!(:closed_by)
      end

      it 'should rollback changes before the error happens' do
        expect(UserConversation.find_by(conversation: open_conversation, staff: clinical).escalated).to eq(true)
        expect(ClosureNote.count).to eq(0)
        expect(open_conversation.close_conversation( close_params)).to eq(false)
        expect(UserConversation.find_by(conversation: open_conversation, staff: clinical).escalated).to eq(true)
        expect(ClosureNote.count).to eq(0)
      end
    end
  end
end
