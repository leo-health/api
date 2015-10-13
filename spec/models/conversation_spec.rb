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
end

  # describe '#escalate_conversation_to_staff' do
  #   let(:open_conversation){ build(:conversation, :open) }
  #   let(:customer_service){ create(:user, :customer_service) }
  #   let(:clinical){ create(:user, :clinical) }
  #   let(:note){ 'escalation note'}
  #   let(:priority){ 1 }
  #
  #   context 'escalate a non-closed conversation' do
  #     let(:escalation_params){{ escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service }}
  #
  #     it 'should create a user_conversation and a escalation_note record, then return true' do
  #       expect( UserConversation.count ).to eq(0)
  #       expect( EscalationNote.count ).to eq(0)
  #       expect( open_conversation.escalate_conversation_to_staff(escalation_params) ).to eq(true))
  #       expect( UserConversation.count ).to eq(1)
  #       expect( EscalationNote.count ).to eq(1)
  #       expect( UserConversation.find_by( user_id: clinical.id, conversation_id: open_conversation.id).escalated ).to eq(true)
  #     end
  #   end
  # end
  #
  # describe '#close_conversation' do
  #   it 'should update user_conversations, create a closure note and return true' do
  #     # expect(open_conversation)
  #   end
  # end

  # describe 'escalate_conversation' do
  #   let(:closed_conversation){ build(:conversation) }
  #   let(:customer_service){ create(:user, :customer_service) }
  #   let(:clinical){ create(:user, :clinical) }
  #   let(:note){ 'escalation note'}
  #   let(:priority){ 1 }
  #
  #   it 'should respond to a instance of conversation class' do
  #     expect(closed_conversation).to respond_to(:escalate_conversation)
  #   end
  #
  #   context 'escalate an already closed conversation' do
  #     it 'should not be able to escalate a closed conversation' do
  #       expect( closed_conversation.escalate_conversation(customer_service.id, clinical.id, note, priority) ).to eq(nil)
  #     end
  #   end
  #
  #   context 'escalate a non-closed conversation' do
  #     let(:open_conversation){ build(:conversation, :open) }
  #
  #     it 'should change the conversation status from open to escalated' do
  #       expect{ open_conversation. escalate_conversation( customer_service.id, clinical.id, note, priority ) }.
  #         to change { open_conversation.status.to_sym }.from( :open ).to( :escalated )
  #     end
  #
  #     it 'should create a user_conversation record to include esclated_to person in the conversation paticipants' do
  #       expect{ open_conversation. escalate_conversation( customer_service.id, clinical.id, note, priority ) }.
  #         to change { UserConversation.count }.from( 0 ).to( 1 )
  #       expect( UserConversation.find_by( user_id: clinical.id, conversation_id: open_conversation.id).escalated ).to eq( true )
  #     end
  #
  #     it 'should change create an escalation note' do
  #       expect{ open_conversation. escalate_conversation( customer_service.id, clinical.id, note, priority ) }.
  #           to change { EscalationNote.count }.from( 0 ).to( 1 )
  #     end
  #   end
  # end

  # describe 'close_conversation' do
  #   let(:open_conversation){ build(:conversation, :open) }
  #   let(:closed_by_user){ create(:user, :customer_service) }
  #   let(:note){ 'close the conversation'}
  #
  #   it 'should respond to a instance of conversation class' do
  #     expect(open_conversation).to respond_to(:close_conversation)
  #   end
  #
  #   context 'close a closed conversation' do
  #     let(:closed_conversation){ build(:conversation) }
  #
  #     it 'should return false' do
  #       expect( closed_conversation.close_conversation( closed_by_user, note ) ).to eq( false )
  #     end
  #   end
  #
  #   context 'close a non closed conversation' do
  #     it 'should update the conversation status to closed' do
  #       expect{ open_conversation.close_conversation( closed_by_user, note ) }.
  #           to change { open_conversation.status.to_sym }.from( :open ).to( :closed )
  #     end
  #
  #     it 'should create a note' do
  #       expect{ open_conversation.close_conversation( closed_by_user, note ) }.
  #           to change{ CloseConversationNote.count }.from(0).to(1)
  #
  #       expect( CloseConversationNote.first.note ).to eq(note)
  #     end
  #   end
  # end

