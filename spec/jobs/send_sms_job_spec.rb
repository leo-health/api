require 'rails_helper'

describe SendSmsJob do
  let(:customer_service_user){ create(:user, :customer_service, phone: "2035223374") }
  let(:send_sms_job){ SendSmsJob.new(customer_service_user.id)}
  let(:response){{ from: TWILIO_PHONE_NUMBER, to: customer_service_user.phone, body: "You have a new message from a Leo Member." }}

  describe '#perform' do
    it "should send the sms via twilio client" do
      send_sms_job.perform
      expect(FakeSms.messages.last.from).to eq(response)
    end
  end

  describe '.send' do
    it "should enqueue job, set cool down period and unpause schedule sms job" do
      expect{ SendSmsJob.send(customer_service_user.id) }.to change(Delayed::Job.where(queue: 'sms_notification'), :count).by(1)
    end
  end
end
