class SendSmsJob < Struct.new(:receiver_id, :body)
  def self.send(receiver_id, body)
    Delayed::Job.enqueue(new(receiver_id, body))
  end

  def perform
    receiver = User.find_by_id(receiver_id)
    sms_user(receiver.phone, body) if receiver
  end

  private

  def sms_user(phone, body)
    TWILIO.messages.create(from: TWILIO_PHONE_NUMBER, to: phone, body: body)
  end
end
