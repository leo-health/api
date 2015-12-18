require 'rails_helper'

RSpec.describe EscalationNote, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user_conversation) }
    it{ is_expected.to belong_to(:escalated_by).class_name('User') }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:escalated_by) }
    it { is_expected.to validate_presence_of(:user_conversation) }
    it { is_expected.to validate_presence_of(:priority) }
  end

  describe "callbacks" do
    let!(:customer_service){ create(:user, :customer_service) }
    let!(:clinical){ create(:user, :clinical) }
    let!(:open_conversation){ create(:conversation, state: :open) }
    let(:escalation_params){ { escalated_to: clinical, note: 'escalation note', priority: 1, escalated_by: customer_service } }

    describe 'after commit' do
      it "should send a sms and email notification to staff" do
        expect( EscalationNote.count ).to eq(0)
        expect{ open_conversation.escalate(escalation_params) }.to change(Delayed::Job, :count).by(2)
        expect( EscalationNote.count ).to eq(1)
      end
    end
  end
end
