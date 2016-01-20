require 'rails_helper'

describe SendSmsJob do
  let!(:customer_service_user){ create(:user, :customer_service, phone: "+19199999282") }
  let!(:sender){ create(:user) }
  let(:body){ "what up bro!"}
  let(:send_sms_job){ SendSmsJob.new(customer_service_user.id, sender.id, :single, Time.now.to_s)}
  let(:response){{ from: TWILIO_PHONE_NUMBER,
                         to: customer_service_user.phone,
                         body: "#{sender.full_name} sent you 1 message!" }}

  describe '#perform' do
    it "should send the sms via twilio client" do
      send_sms_job.perform
      expect(FakeSms.messages.last.from).to eq(response)
    end
  end

  describe '.send' do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    it "should enqueue job, set cool down period and unpause schedule sms job" do
      expect{ SendSmsJob.send(customer_service_user.id, sender.id, :batched, Time.now.to_s) }.to change(Delayed::Job, :count).by(1)
      expect( $redis.get("#{ customer_service_user.id }batch_scheduled?") ).to eq('false')
      expect( $redis.get("#{ customer_service_user.id }next_messageAt") ).to eq( (Time.now + 2.minutes).to_s )
    end
  end
end
