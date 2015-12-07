require 'rails_helper'

describe SendSmsJob do
  let!(:customer_service_user){ create(:user, :customer_service, phone: "+19199999282") }
  let(:body){ "what up bro!"}
  let(:send_sms_job){ SendSmsJob.new(customer_service_user.id, body)}
  let(:response){{ from: TWILIO_PHONE_NUMBER,
                         to: customer_service_user.phone,
                         body: body }}

  describe '#perform' do
    it "should send the sms via twilio client" do
      send_sms_job.perform
      expect(FakeSms.messages.last.from).to eq(response)
    end
  end

  describe '#send' do
    it "should send the sms via delayed_job" do
      expect{ send_sms_job.send }.to change(Delayed::Job, :count).by(1)
    end
  end
end
