class SendSmsJob < Struct.new(:receiver_id, :body)
  def perform
    receiver = User.find_by_id(receiver_id)
    sms_user(receiver.phone, body)
  end

  def send
    Delayed::Job.enqueue self
  end

  private

  def sms_user(phone, body)
    TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
  end
end
