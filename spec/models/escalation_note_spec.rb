require 'rails_helper'

RSpec.describe EscalationNote, type: :model do
  let!(:customer_service){ create(:user, :customer_service) }
  let!(:clinical){ create(:user, :clinical) }
  let!(:conversation){ create(:conversation, state: :open) }
  let(:escalation_params){ { escalated_to: clinical, note: 'escalation note', priority: 1, escalated_by: customer_service } }

  describe "relations" do
    it{ is_expected.to belong_to(:escalated_to).class_name('User') }
    it{ is_expected.to belong_to(:escalated_by).class_name('User') }
    it{ is_expected.to belong_to(:conversation) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:escalated_by) }
    it { is_expected.to validate_presence_of(:escalated_to) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_presence_of(:conversation) }
  end

  describe "callbacks" do
    describe 'after commit' do
      before do
        new_time = Time.local(2016, 1, 1, 2, 0, 0)
        Timecop.freeze(new_time)
      end

      after do
        Timecop.return
      end

      it "should send a email notification to staff" do
        expect( EscalationNote.count ).to eq(0)
        expect{ conversation.escalate(escalation_params) }.to change(Delayed::Job, :count).by(1)
        expect( EscalationNote.count ).to eq(1)
      end
    end
  end

  describe "#active?" do
    let!(:closure_params){ { closed_by: clinical, note: 'closure note', closure_reason_id: 1} }

    before do
      conversation.escalate(escalation_params)
      conversation.close(closure_params)
    end

    it "should determine if the escalation note is active or not" do
      expect( conversation.escalation_notes.first.active? ).to eq(false)
    end
  end
end
