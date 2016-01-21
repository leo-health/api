require 'rails_helper'

describe Conversation, type: :model do
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:bot){ create(:user, :bot)}

  describe 'relations' do
    it{ is_expected.to have_many(:escalation_notes) }
    it{ is_expected.to have_many(:messages) }
    it{ is_expected.to have_many(:user_conversations) }
    it{ is_expected.to have_many(:staff).class_name('User').through(:user_conversations) }
    it{ is_expected.to have_many(:closure_notes) }
    it{ is_expected.to belong_to(:family) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:family) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe '.sort_conversations' do
    let!(:open_conversation){ create(:conversation, state: :open, updated_at: 10.minutes.ago) }
    let!(:latest_open_conversation){ create(:conversation, state: :open, updated_at: 5.minutes.ago) }
    let!(:closed_conversation){ create(:conversation, updated_at: 10.minutes.ago) }
    let!(:latest_closed_conversation){ create(:conversation, updated_at: 5.minutes.ago) }
    let!(:escalated_conversation){ create(:conversation, state: :escalated, updated_at: 10.minutes.ago) }
    let!(:latest_escalated_conversation){ create(:conversation, state: :escalated, updated_at: 5.minutes.ago) }

    it "should sort the conversations by status filed in oepn, escalated, closed order, and updated_at filed in descending order" do
      sorted_conversation = [ latest_open_conversation, open_conversation,
                              latest_escalated_conversation, escalated_conversation,
                              latest_closed_conversation, closed_conversation ]
      expect( Conversation.sort_conversations ).to match_array( sorted_conversation )
    end
  end

  describe "state machines - conversations" do
    let(:open_conversation){ create(:conversation, state: :open) }
    let(:escalated_conversation){ create(:conversation, state: :escalated) }
    let(:closed_conversation){ create(:conversation) }
    let(:customer_service){ create(:user, :customer_service) }

    describe "#escalate" do
      let(:clinical){ create(:user, :clinical) }
      let(:note){ 'escalation note'}
      let(:priority){ 1 }
      let(:escalation_params){ { escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service } }

      context "open conversation" do
        it 'should change conversation status' do
          expect( open_conversation.state.to_sym ).to eq(:open)
          expect( open_conversation.escalate(escalation_params) ).to eq(true)
          expect( open_conversation.state.to_sym ).to eq(:escalated)
        end
      end

      context 'escalated conversation' do
        it "should change conversation status" do
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
          expect( escalated_conversation.escalate(escalation_params) ).to eq(true)
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
        end
      end

      context 'closed conversation' do
        it "should not change the status" do
          expect( closed_conversation.state.to_sym ).to eq(:closed)
          expect( closed_conversation.escalate(escalation_params) ).to eq(false)
          expect( closed_conversation.state.to_sym ).to eq(:closed)
        end
      end
    end

    describe "#close" do
      let(:note){ 'close the conversation'}
      let(:clinical){ create(:user, :clinical) }
      let(:close_params){ {closed_by: customer_service, note: note} }

      context 'open_conversation' do
        it "should change conversation status to false" do
          expect( open_conversation.state.to_sym ).to eq(:open)
          expect( open_conversation.close(close_params) ).to eq(true)
          expect( open_conversation.state.to_sym ).to eq(:closed)
        end
      end

      context 'escalated conversation' do
        it "should change conversation status to false" do
          expect( escalated_conversation.state.to_sym ).to eq(:escalated)
          expect( escalated_conversation.close(close_params) ).to eq(true)
          expect( escalated_conversation.state.to_sym ).to eq(:closed)
        end
      end

      context 'closed conversation' do
        it "should return false" do
          expect( closed_conversation.close(close_params) ).to eq(false)
        end
      end
    end
  end

  describe '#escalate_conversation_to_staff' do
    let!(:open_conversation){ create(:conversation, state: :open) }
    let(:clinical){ create(:user, :clinical) }
    let(:note){ 'escalation note'}
    let(:priority){ 1 }
    let(:escalation_params){{ escalated_to: clinical, note: note, priority: priority, escalated_by: customer_service }}

    context 'successfully escalate a non-closed conversation' do
      it 'should create a user_conversation and a escalation_note record' do
        expect( EscalationNote.count ).to eq(0)
        open_conversation.escalate_conversation_to_staff(escalation_params)
        expect( EscalationNote.count ).to eq(1)
      end
    end
  end

  describe '#close_conversation' do
    let(:open_conversation){ create(:conversation, state: :open) }
    let(:note){ 'close the conversation'}
    let(:clinical){ create(:user, :clinical) }
    let(:close_params){{closed_by: customer_service, note: note}}

    before do
      escalation_params = { escalated_to: clinical, note: note, escalated_by: customer_service }
      open_conversation.escalate_conversation_to_staff(escalation_params)
    end

    context 'successfully close a non closed conversation' do
      it 'should create a closure note' do
        expect(ClosureNote.count).to eq(0)
        expect(!!open_conversation.close_conversation( close_params)).to eq(true)
        expect(ClosureNote.count).to eq(1)
      end
    end
  end

  describe '#last_closed_at' do
    let(:closed_conversation){ create(:conversation, state: :closed) }
    let!(:first_closure_note){ create(:closure_note, conversation: closed_conversation)}
    let!(:second_closure_note){ create(:closure_note, conversation: closed_conversation, created_at: Time.now + 1.minutes)}

    it "should return the created_at time of second closure note" do
      expect( closed_conversation.last_closed_at ).to eq( second_closure_note.created_at )
    end
  end
end
