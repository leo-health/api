require 'rails_helper'

describe Conversation, type: :model do
	describe 'relations' do
		it{ is_expected.to have_many(:messages) }
		it{ is_expected.to have_many(:user_conversations) }
		it{ is_expected.to have_many(:staff).class_name('User').through(:user_conversations) }
    it{ is_expected.to have_many(:conversation_changes) }
    it{ is_expected.to have_many(:closure_notes) }

    it{ is_expected.to belong_to(:family) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:family) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe 'self.sort_conversations' do
    let!(:open_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_open_conversation){ create(:conversation, updated_at: 5.minutes.ago) }
    let!(:closed_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_closed_conversation){ create(:conversation, updated_at: 5.minutes.ago) }
    let!(:escalated_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_escalated_conversation){ create(:conversation, updated_at: 5.minutes.ago) }

    before do
      open_conversation.update_attributes(state: :open)
      latest_open_conversation.update_attributes(state: :open)
      escalated_conversation.update_attributes(state: :escalated)
      latest_escalated_conversation.update_attributes(state: :escalated)
    end

    it "should sort the conversations by status filed in oepn, escalated, closed order, and updated_at filed in descending order" do
      sorted_conversation = [latest_open_conversation, open_conversation, latest_escalated_conversation, escalated_conversation, latest_closed_conversation, closed_conversation]
      expect( Conversation.sort_conversations ).to eq( sorted_conversation )
    end
  end

  describe "state machines - conversations" do
    describe "escalate" do
      let(:customer_service){ create(:user, :customer_service) }
      let(:clinical){ create(:user, :clinical) }
      let(:note){ 'escalation note'}
      let(:priority){ 1 }
      let(:escalation_params){{ escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service }}

      context "open conversation" do
        let(:open_conversation){ build(:conversation, :open) }

        it 'should change conversation status' do
          expect( open_conversation.state.to_sym ).to eq(:open)
          expect( open_conversation.escalate(escalation_params) ).to eq(true)
          expect( open_conversation.state.to_sym ).to eq(:escalated)
        end
      end

      context 'escalated conversation' do
        let(:escalated_conversation){ build(:conversation, :escalated) }

        it "should change conversation status" do
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
          expect( escalated_conversation.escalate(escalation_params) ).to eq(true)
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
        end
      end

      context 'closed conversation' do
        let(:closed_conversation){ build(:conversation) }

        it "should not change the status" do
          expect( closed_conversation.state.to_sym ).to eq(:closed)
          expect( closed_conversation.escalate(escalation_params) ).to eq(false)
          expect( closed_conversation.state.to_sym ).to eq(:closed)
        end
      end
    end

    describe "close" do
      let(:note){ 'close the conversation'}
      let(:clinical){ create(:user, :clinical) }
      let(:customer_service){ create(:user, :customer_service) }
      let(:close_params){{closed_by: customer_service, note: note}}

      context 'open_conversation' do
        let(:open_conversation){ build(:conversation, :open) }

        it "should change conversation status to false" do
          expect( open_conversation.state.to_sym ).to eq(:open)
          expect( open_conversation.close(close_params) ).to eq(true)
          expect( open_conversation.state.to_sym ).to eq(:closed)
        end
      end

      context 'escalated conversation' do
        let(:escalated_conversation){ build(:conversation, :escalated) }

        it "should change conversation status to false" do
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
          expect( escalated_conversation.close(close_params) ).to eq(true)
          expect( escalated_conversation.state.to_sym ).to eq(:closed)
        end
      end

      context 'closed conversation' do
        let(:closed_conversation){ build(:conversation) }

        it "should return false" do
          expect( closed_conversation.close(close_params) ).to eq(false)
        end
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
