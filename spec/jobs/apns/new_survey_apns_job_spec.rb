require 'rails_helper'

describe NewSurveyApnsJob do
  let(:device_token){ "test_token" }
  let(:new_survey_apns_job){ NewSurveyApnsJob.new(device_token) }

  describe '#perform' do
    before do
      @server = Grocer.server(port: 2195)
      @server.accept
    end

    after do
      @server.close
    end

    it "should send the apns notification" do
      new_survey_apns_job.perform

      Timeout.timeout(3) {
        notification = @server.notifications.pop
        expect(notification.alert).to eq("You have a new survey")
      }
    end
  end

  describe '.send' do
    it "should enqueue job, set cool down period and unpause schedule sms job" do
      expect{ NewSurveyApnsJob.send(:device_token) }.to change(Delayed::Job.where(queue: 'apns_notification'), :count).by(1)
    end
  end
end
