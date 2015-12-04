require'rails_helper'

describe SmsNotification do
  describe "#send" do
    context "with valid numbers" do
      let(:test_number){ "+19192659848" }
      let(:body){ "Hello" }
      subject(:sms_notification){SmsNotification.new(TWILIO_PHONE_NUMBER, test_number)}

      it "should send a sms to the receiver" do
        mock_client = mock('twilio client')
        Twilio::REST::Client.stub(:new).and_return(mock_client)
        SmsNotification.should_receive()
        sms_notification.send(body)
      end
    end
  end
end
