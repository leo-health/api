require 'rails_helper'

describe OperatePracticeJob do
  let!(:practice){ create(:practice) }

  describe '.start' do
    it "should enqueue open office job and close office job and switch-off victoria and erin" do
      expect{ OperatePracticeJob.start(practice.id) }.to change(Delayed::Job, :count).by(3)
    end
  end

  describe '#perform' do
    context "when close practice" do
      let(:close_practice_job){ OperatePracticeJob.new(practice.id, :close)}

      it "should start after office hours" do
        expect(close_practice_job).to receive(:start_after_office_hours)
        close_practice_job.perform
      end
    end

    context "when open practice" do
      let(:open_practice_job){ OperatePracticeJob.new(practice.id, :open)}

      it "should start in office hours" do
        expect(open_practice_job).to receive(:start_in_office_hours)
        open_practice_job.perform
      end
    end

    context "when close victoria and erin" do
      let(:close_vi_and_er){ OperatePracticeJob.new(practice.id)}

      it "should update the status for Erin and Victoria" do
        expect(close_vi_and_er).to receive(:close_vi_and_er)
        close_vi_and_er.perform
      end
    end
  end
end
